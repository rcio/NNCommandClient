//
//  NNConnectionManager.m
//  NNCommandClient
//
//  Created by Rico on 9/17/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import "NNConnectionManager.h"
#import "NNTCPConnection.h"
#import "NNRWLock.h"
#import "NNProtocolRequest.h"
#import "NNCommandClient.h"

@interface NNRsponserObj : NSObject

@property (nonatomic) NSInteger mesgSeq;
@property (nonatomic) uint32_t cmd;
@property (nonatomic) NSDictionary *body;
@property (nonatomic) id <NNConnectionResponseDelegate> responser;
@property (nonatomic) NSDate *startTime;

@end

@implementation NNRsponserObj

@end

@interface NNConnectionManager () <NNTCPConnectionDelegate>

@property (nonatomic) NNTCPConnection *connection;

@property (nonatomic) NSMutableArray *sendBuffer;
@property (nonatomic) NNRWLock *sendBufferLock;

@property (nonatomic) NSMutableDictionary *responseDict;
@property (nonatomic) NNRWLock *responseDictLock;

@property (nonatomic) NNProtocolResponse *response;

@property (nonatomic) NSInteger mesgSeq;

@property (nonatomic) BOOL running;

@end

@implementation NNConnectionManager
+ (id)instence {
    static NNConnectionManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    _sendBuffer = [[NSMutableArray alloc] init];
    _responseDict = [[NSMutableDictionary alloc] init];
    
    _mesgSeq = 1;

    _connection = [[NNTCPConnection alloc] init];
    _connection.host = [[NNCommandClient sharedClient] serverName];
    _connection.port = [[NNCommandClient sharedClient] serverPort];
    
    NSAssert(_connection.host, @"You should call [NNCommandClient connectToServer:port]");
    NSAssert(_connection.port, @"You should call [NNCommandClient connectToServer:port]");
    
    _connection.delegate = self;
    [_connection connect];
    
    self.running = YES;
    
    return self;
}

#pragma mark - Getter
- (NNProtocolResponse *)response {
    if (_response == nil) {
        _response = [[NNProtocolResponse alloc] init];
    }
    
    return _response;
}

#pragma mark - API
- (void)sendRequestCmd:(uint32_t)cmd body:(NSDictionary *)requestBody responser:(id)responser {
    run_block_in_queue_async(NNNetworkQueue, ^{
        NNRsponserObj *obj = [[NNRsponserObj alloc] init];
        obj.mesgSeq = self.mesgSeq;
        obj.cmd = cmd;
        obj.body = requestBody;
        obj.responser = responser;
        obj.startTime = [NSDate date];
        
        [_sendBufferLock lockWrite];
        [self.sendBuffer addObject:obj];
        [_sendBufferLock unLockRead];
        
        [_responseDictLock lockWrite];
        [self.responseDict setObject:obj forKey:@(self.mesgSeq)];
        [_responseDictLock unLockWrite];
        
        self.mesgSeq++;
        [self reSched];
    });
}


#pragma mark - Internal Function
- (void)reSched {
    if (self.running == YES) {
        return;
    }

    if (self.sendBuffer.count > 0) {
        self.running = YES;
        
        [_sendBufferLock lockRead];
        NNRsponserObj *one = [self.sendBuffer objectAtIndex:0];
        [_sendBufferLock unLockRead];
        
        NNProtocolRequest *request = [[NNProtocolRequest alloc] init];
        request.seq = one.mesgSeq;
        request.cmd = one.cmd;
        request.body = one.body;
        
        NNLogInfo(kLogModuleCommandClient, @"Connection Manager Send Request %p, seq %u, cmd %u", request, request.seq, request.cmd);
        [self.connection sendData:[request requestData]];

        [_sendBufferLock lockWrite];
        [self.sendBuffer removeObject:one];
        [_sendBufferLock unLockWrite];
    }
}

#pragma mark - NNTCPConnectionDelegate
- (void)connectionReadyToWrite {
    run_block_in_queue_async(NNNetworkQueue, ^{
        self.running = NO;
        [self reSched];
    });
}

- (void)connectionDidReceiveData:(NSData *)data {
    run_block_in_queue_async(NNNetworkQueue, ^{
        NSData *left = nil;
        do {
            if ([self.response appendData:data left:&left]) {
                [_responseDictLock lockRead];
                NNRsponserObj *obj = [self.responseDict objectForKey:@(self.response.seq)];
                [_responseDictLock unLockRead];
                
                if (obj) {
                    [obj.responser bbConnectionDidReceiveResponseBody:self.response.body errCode:self.response.ret];
                }
                
                [_responseDictLock lockWrite];
                [self.responseDict removeObjectForKey:@(self.response.seq)];
                [_responseDictLock unLockWrite];
                
                self.response = nil;
            }
        } while (left && left.length);
    });
}
@end
