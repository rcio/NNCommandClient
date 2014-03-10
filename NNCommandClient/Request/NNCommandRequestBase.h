//
//  NNRequestBase.h
//  NNCommandClient
//
//  Created by Rico on 9/22/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NNRequestCMD) {
    CMD_FindPeople = 1001
};

@interface NNCommandRequestBase : NSObject

@property (nonatomic, assign) uint32_t retCode;
- (NNRequestCMD)requestCmd;
- (NSDictionary *)requestBody;

- (void)handleResponseBody:(NSDictionary *)body errCode:(uint32_t)code;

- (void)sendRequest;
@end
