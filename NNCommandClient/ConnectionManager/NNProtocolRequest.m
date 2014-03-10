//
//  NNProtocolRequest.m
//  NNCommandClient
//
//  Created by fei on 9/22/13.
//  Copyright (c) 2013 fei. All rights reserved.
//

#import "NNProtocolRequest.h"
#import "JSONKit.h"

struct bbRquestHeader {
    uint32_t magic;
	uint32_t seq;
	uint32_t cmd;
	uint32_t body_length;
	uint32_t flag;
	uint32_t reserv1;
	uint32_t reserv2;
};

@implementation NNProtocolRequest

- (NSData *)requestData {
    struct bbRquestHeader header = {0};
    
    header.magic = 0x12345678;
    header.seq = self.seq;
    header.cmd = self.cmd;
    
    NSData *bodyData = [self.body JSONData];
    header.body_length = (uint32_t)bodyData.length;
    
    NSMutableData *resData = [[NSMutableData alloc] init];
    [resData appendBytes:&header length:sizeof(header)];
    [resData appendData:bodyData];
    
    return [NSData dataWithData:resData];
}

@end
