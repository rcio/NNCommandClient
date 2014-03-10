//
//  NNConnectionManager.h
//  NNCommandClient
//
//  Created by Rico on 9/17/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNProtocolResponse.h"

@protocol NNConnectionResponseDelegate

- (void)bbConnectionDidReceiveResponseBody:(NSDictionary *)body errCode:(uint32_t)error;

@end

@interface NNConnectionManager : NSObject
+ (id)instence;

- (void)sendRequestCmd:(uint32_t)cmd body:(NSDictionary *)requestBody responser:(id)responser;

@end
