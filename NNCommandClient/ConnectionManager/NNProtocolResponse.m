//
//  NNProtocolPackage.m
//  NNCommandClient
//
//  Created by Rico on 9/17/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import "NNProtocolResponse.h"
#import "JSONKit.h"

struct bbResponseHeader {
    uint32_t magic;
	uint32_t seq;
    uint32_t cmd;
	uint32_t ret;
	uint32_t body_length;
	uint32_t flag;
	uint32_t reserv1;
	uint32_t reserv2;
};


@interface NNProtocolResponse ()

@property (nonatomic) NSMutableData *buffer;

@end


@implementation NNProtocolResponse

- (NSMutableData *)buffer {
    if (!_buffer) {
        _buffer = [[NSMutableData alloc] init];
    }
    
    return _buffer;
}

#pragma mark - 
- (BOOL)appendData:(NSData *)data left:(NSData **)leftData {
    [self.buffer appendData:data];
    
    if (self.buffer.length < sizeof(struct bbResponseHeader)) {
        return NO;
    }
    else {
        [self parseHeader];
    }
    
    int packetLength = sizeof(struct bbResponseHeader) + self.bodyLength;
    if (self.buffer.length < packetLength) {
        return NO;
    }
    else if (self.buffer.length > packetLength) {
        NSUInteger cutLent = self.buffer.length - packetLength;
        *leftData = [NSData dataWithBytes:self.buffer.bytes + packetLength length:cutLent];
        self.buffer = [NSData dataWithBytes:self.buffer.bytes length:packetLength];
    }
    
    [self parseBody];
    return YES;
}

- (void)parseHeader {
    struct bbResponseHeader *header = (struct bbResponseHeader *)self.buffer.bytes;
    self.magic = header->magic;
    self.ret = header->ret;
    self.cmd = header->cmd;
    self.seq = header->seq;
    self.bodyLength = header->body_length;
    self.flag = header->flag;
    self.reserv1 = header->reserv1;
    self.reserv2 = header->reserv2;
}

- (void)parseBody {
    NSData *jsonData = [NSData dataWithBytes:self.buffer.bytes + sizeof(struct bbResponseHeader)
                                      length:self.buffer.length - sizeof(struct bbResponseHeader)];
    self.body = [[JSONDecoder decoder] objectWithData:jsonData];
}
@end
