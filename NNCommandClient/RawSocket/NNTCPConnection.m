//
//  NNTCPConnection.m
//  NNCommandClient
//
//  Created by Rico on 9/10/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import "NNTCPConnection.h"
#import "GCDAsyncSocket.h"

static NSString *queueName = @"socketQueue.NNCommandClient";

@interface NNTCPConnection () <GCDAsyncSocketDelegate>

@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic) GCDAsyncSocket *socket;

@end

@implementation NNTCPConnection
- (id)init {
    self = [super init];
    
    _socketQueue = [[NNQueueManager sharedManager] createSerialQueueForName:queueName];
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    
    return self;
}

#pragma mark - API
- (void)connect {
    NSError *error = nil;
    [self.socket connectToHost:self.host onPort:self.port withTimeout:10 error:&error];
    if (error) {
        NNLogInfo(kLogModuleCommandClient, @"Connect error %@", error);
    }
}

- (void)sendData:(NSData *)data {
    [self.socket writeData:data withTimeout:10 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NNLogInfo(kLogModuleCommandClient, @"Connection did connect to %@:%u", host, port);
    [_delegate connectionReadyToWrite];

    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [_delegate connectionDidReceiveData:data];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [_delegate connectionReadyToWrite];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    dispatch_async(_socketQueue, ^{
        NNLogInfo(kLogModuleCommandClient, @"Connection disconnect, sleep 3 sec for reconnect...");
        sleep(3);
        [self connect];
    });
    
    [self.socket readDataWithTimeout:-1 tag:0];
}

@end
