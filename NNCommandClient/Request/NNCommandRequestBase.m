//
//  NNRequestBase.m
//  NNCommandClient
//
//  Created by Rico on 9/22/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import "NNCommandRequestBase.h"
#import "NNConnectionManager.h"

@implementation NNCommandRequestBase

- (NNRequestCMD)requestCmd {
    return 0;
}

- (NSDictionary *)requestBody {
    assert(0);
    return nil;
}


- (void)handleResponseBody:(NSDictionary *)body errCode:(uint32_t)code {
    self.retCode = code;
    
    NSLog(@"Request : %p code: %u body: %@", self, code, body);
    
    return;
}

- (void)sendRequest {
    [[NNConnectionManager instence] sendRequestCmd:self.requestCmd
                                              body:self.requestBody
                                         responser:self];
}
@end
