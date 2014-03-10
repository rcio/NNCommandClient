//
//  NNCommandClient.m
//  NNCommandClient
//
//  Created by Rico on 14-3-10.
//  Copyright (c) 2014年 Rcio. All rights reserved.
//

#import "NNCommandClient.h"
#import "NNConnectionManager.h"

NSString *kLogModuleCommandClient = @"CommandClient";

@interface NNCommandClient()

@property (nonatomic) NSString *serverName;
@property (nonatomic) uint16_t serverPort;

@end

@implementation NNCommandClient

+ (id)sharedClient {
    static NNCommandClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (void)connectToServer:(NSString *)serverName port:(uint16_t)port {
    assert(serverName);
    assert(port);
    
    self.serverName = serverName;
    self.serverPort = port;
    
    [NNConnectionManager instence];
}
@end
