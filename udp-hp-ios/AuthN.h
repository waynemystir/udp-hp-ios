//
//  AuthN.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/31/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthN : NSObject

+ (NSString *)loggedInLastTimeUserName;
+ (void)setLoggedInLastTimeUserName:(NSString *)username;

+ (void)addUsername:(NSString *)username andPassword:(NSString *)password;

+ (NSString *)getPasswordForUsername:(NSString *)username;
+ (void)setPassword:(NSString *)password forUsername:(NSString *)username;

+ (const char *)getRSAPubKey;
+ (void)setRSAPubKey:(char *)rsapubk;

+ (const char *)getRSAPriKey;
+ (void)setRSAPriKey:(char *)rsaprik;

+ (unsigned char *)getAESKey;
+ (size_t)getSizeOfAESKey;
+ (void)setAESKey:(NSData *)key;

+ (void)Signout;

@end
