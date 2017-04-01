//
//  AuthN.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/31/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "AuthN.h"
#import "udp_client.h"
#import "crypto_wrapper.h"
#import "WESKeyChain.h"

NSString * const kKeyLoggedInLastTimeUserName = @"kKeyLoggedInLastTimeUserName";
NSString * const kKeyRSAPublicKey = @"kKeyRSAPublicKey";
NSString * const kKeyRSAPrivateKey = @"kKeyRSAPrivateKey";
NSString * const kKeyAESKey = @"kKeyAESKey";
NSString * const kKeyUsernames = @"kKeyUsernames";

@implementation AuthN

+ (NSString *)loggedInLastTimeUserName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kKeyLoggedInLastTimeUserName];
}

+ (void)setLoggedInLastTimeUserName:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:kKeyLoggedInLastTimeUserName];
}

+ (void)addUsername:(NSString *)username andPassword:(NSString *)password {
    if (!username || !password) return;
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *a = [[sud arrayForKey:kKeyUsernames] mutableCopy];
    if (!a) {
        a = [@[username] mutableCopy];
    } else if (![a containsObject:username]) {
        [a addObject:username];
    }
    [sud setObject:a forKey:kKeyUsernames];
    [self setPassword:password forUsername:username];
}

+ (NSString *)getPasswordForUsername:(NSString *)username {
    return [WESKeyChain objectForKey:[self passwordKeyForUsername:username]];
}

+ (void)setPassword:(NSString *)password forUsername:(NSString *)username {
    [WESKeyChain setObject:password forKey:[self passwordKeyForUsername:username]];
}

+ (const char *)getRSAPubKey {
    return [[WESKeyChain objectForKey:kKeyRSAPublicKey] UTF8String];
}

+ (void)setRSAPubKey:(char *)rsapubk {
    [WESKeyChain setObject:[NSString stringWithUTF8String:rsapubk] forKey:kKeyRSAPublicKey];
}

+ (const char *)getRSAPriKey {
    return [[WESKeyChain objectForKey:kKeyRSAPrivateKey] UTF8String];
}

+ (void)setRSAPriKey:(char *)rsaprik {
    [WESKeyChain setObject:[NSString stringWithUTF8String:rsaprik] forKey:kKeyRSAPrivateKey];
}

+ (unsigned char *)getAESKey {
    return (unsigned char *)[[WESKeyChain objectForKey:kKeyAESKey] bytes];
}

+ (size_t)getSizeOfAESKey {
    return sizeof([self getAESKey]);
}

+ (void)setAESKey:(NSData *)key {
    [WESKeyChain setObject:key forKey:kKeyAESKey];
}

+ (void)Signout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeyLoggedInLastTimeUserName];
}

+ (NSString *)passwordKeyForUsername:(NSString *)username {
    return [NSString stringWithFormat:@"%@suppasswordkey", username];
}

@end
