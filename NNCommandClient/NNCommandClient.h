//
//  NNCommandClient.h
//  NNCommandClient
//
//  Created by Rico on 14-3-10.
//  Copyright (c) 2014年 Rcio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNCommandRequestBase.h"

extern NSString *kLogModuleCommandClient;

@interface NNCommandClient : NSObject

@property (nonatomic, readonly) NSString *serverName;
@property (nonatomic, readonly) uint16_t serverPort;

+ (id)sharedClient;
- (void)connectToServer:(NSString *)serverName port:(uint16_t)port;

@end
