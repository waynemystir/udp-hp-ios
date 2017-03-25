//
//  WESKeyChain.h
//  Keychainer
//
//  Created by WAYNE SMALL on 3/25/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WESKeychainAccess)
{
    WESKeychainAccessibleWhenUnlocked = 0,
    WESKeychainAccessibleAfterFirstUnlock,
    WESKeychainAccessibleAlways,
    WESKeychainAccessibleWhenUnlockedThisDeviceOnly,
    WESKeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    WESKeychainAccessibleAlwaysThisDeviceOnly
};

@interface WESKeyChain : NSObject

+ (BOOL)setObject:(id)object forKey:(id)key;
+ (id)objectForKey:(id)key;
+ (BOOL)removeObjectForKey:(id)key;

@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *accessGroup;
@property (nonatomic, assign) WESKeychainAccess accessibility;

@end
