//
//  NNProtocolPackage.h
//  NNCommandClient
//
//  Created by fei on 9/17/13.
//  Copyright (c) 2013 fei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNProtocolResponse : NSObject

@property (nonatomic) uint32_t magic;
@property (nonatomic) uint32_t seq;
@property (nonatomic) uint32_t cmd;
@property (nonatomic) uint32_t ret;
@property (nonatomic) uint32_t bodyLength;
@property (nonatomic) uint32_t flag;
@property (nonatomic) uint32_t reserv1;
@property (nonatomic) uint32_t reserv2;

@property (nonatomic) NSDictionary *body;

- (BOOL)appendData:(NSData *)data left:(NSData **)leftData;
@end
