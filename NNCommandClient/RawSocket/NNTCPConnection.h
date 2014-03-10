//
//  NNTCPConnection.h
//  NNCommandClient
//
//  Created by Rico on 9/10/13.
//  Copyright (c) 2013 Rico. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NNTCPConnectionDelegate;


@interface NNTCPConnection : NSObject

@property (nonatomic) NSString *host;
@property (nonatomic) uint16_t port;

@property (nonatomic, weak) NSObject <NNTCPConnectionDelegate> *delegate;

- (void)connect;
- (void)sendData:(NSData *)data;
@end


@protocol NNTCPConnectionDelegate
@required
- (void)connectionReadyToWrite;
- (void)connectionDidReceiveData:(NSData *)data;

@end