//
//  NNProtocolRequest.h
//  NNCommandClient
//
//  Created by fei on 9/22/13.
//  Copyright (c) 2013 fei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNProtocolRequest : NSObject

@property (nonatomic) uint32_t seq;
@property (nonatomic) uint32_t cmd;
@property (nonatomic) NSDictionary *body;

- (NSData *)requestData;

@end
