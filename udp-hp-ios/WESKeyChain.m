//
//  WESKeyChain.m
//  Keychainer
//
//  Created by WAYNE SMALL on 3/25/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "WESKeyChain.h"

@implementation WESKeyChain

+ (instancetype)defaultKeychain
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        sharedInstance = [[WESKeyChain alloc] initWithService:bundleID
                                                 accessGroup:nil];
    });
    
    return sharedInstance;
}

- (id)init
{
    return [self initWithService:nil accessGroup:nil];
}

- (id)initWithService:(NSString *)service
          accessGroup:(NSString *)accessGroup
{
    return [self initWithService:service
                     accessGroup:accessGroup
                   accessibility:WESKeychainAccessibleAlways];
}

- (id)initWithService:(NSString *)service
          accessGroup:(NSString *)accessGroup
        accessibility:(WESKeychainAccess)accessibility
{
    if ((self = [super init]))
    {
        _service = [service copy];
        _accessGroup = [accessGroup copy];
        _accessibility = accessibility;
    }
    return self;
}

+ (BOOL)setObject:(id)object forKey:(id)key {
    WESKeyChain *w = [self defaultKeychain];
    return [w setObject:object forKey:key];
}

+ (id)objectForKey:(id)key {
    WESKeyChain *w = [self defaultKeychain];
    return [w objectForKey:key];
}

+ (BOOL)removeObjectForKey:(id)key {
    WESKeyChain *w = [self defaultKeychain];
    return [w removeObjectForKey:key];
}

- (NSData *)dataForKey:(id)key
{
    //generate query
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if ([self.service length]) query[(__bridge NSString *)kSecAttrService] = self.service;
    query[(__bridge NSString *)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge NSString *)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge NSString *)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge NSString *)kSecAttrAccount] = [key description];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    if ([_accessGroup length]) query[(__bridge NSString *)kSecAttrAccessGroup] = _accessGroup;
    
#endif
    
    //recover data
    CFDataRef data = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&data);
    if (status != errSecSuccess && status != errSecItemNotFound)
    {
        NSLog(@"FXKeychain failed to retrieve data for key '%@', error: %ld", key, (long)status);
    }
    return CFBridgingRelease(data);
}

- (BOOL)setObject:(id)object forKey:(id)key
{
    NSLog(@"setObject (%@)(%@)(%@)(%@)", self.service, self.accessGroup, key, object);
    //generate query
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if ([self.service length]) query[(__bridge NSString *)kSecAttrService] = self.service;
    query[(__bridge NSString *)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge NSString *)kSecAttrAccount] = [key description];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    if ([_accessGroup length]) query[(__bridge NSString *)kSecAttrAccessGroup] = _accessGroup;
    
#endif
    
    //encode object
    NSData *data = nil;
    NSError *error = nil;
    if ([(id)object isKindOfClass:[NSString class]])
    {
        //check that string data does not represent a binary plist
        NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
        if (![object hasPrefix:@"bplist"] || ![NSPropertyListSerialization propertyListWithData:[object dataUsingEncoding:NSUTF8StringEncoding]
                                                                                        options:NSPropertyListImmutable
                                                                                         format:&format
                                                                                          error:NULL])
        {
            //safe to encode as a string
            data = [object dataUsingEncoding:NSUTF8StringEncoding];
        }
    } else if ([object isKindOfClass:[NSData class]]) {
        data = object;
    }
    
    //fail if object is invalid
    NSAssert(!object || (object && data), @"FXKeychain failed to encode object for key '%@', error: %@", key, error);
    
    if (data)
    {
        //update values
        NSMutableDictionary *update = [@{(__bridge NSString *)kSecValueData: data} mutableCopy];
        
#if TARGET_OS_IPHONE || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9
        
        update[(__bridge NSString *)kSecAttrAccessible] = @[(__bridge id)kSecAttrAccessibleWhenUnlocked,
                                                            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                                            (__bridge id)kSecAttrAccessibleAlways,
                                                            (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                            (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                                            (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly][self.accessibility];
#endif
        
        //write data
        OSStatus status = errSecSuccess;
        if ([self dataForKey:key])
        {
            //there's already existing data for this key, update it
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
        }
        else
        {
            //no existing data, add a new item
            [query addEntriesFromDictionary:update];
            status = SecItemAdd ((__bridge CFDictionaryRef)query, NULL);
        }
        if (status != errSecSuccess)
        {
            NSLog(@"FXKeychain failed to store data for key '%@', error: %ld", key, (long)status);
            return NO;
        }
    }
//    else if (self[key])
//    {
//        //delete existing data
//        
//#if TARGET_OS_IPHONE
//        
//        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
//#else
//        CFTypeRef result = NULL;
//        query[(__bridge id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
//        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
//        if (status == errSecSuccess)
//        {
//            status = SecKeychainItemDelete((SecKeychainItemRef) result);
//            CFRelease(result);
//        }
//#endif
//        if (status != errSecSuccess)
//        {
//            NSLog(@"FXKeychain failed to delete data for key '%@', error: %ld", key, (long)status);
//            return NO;
//        }
//    }
    return YES;
}

- (BOOL)removeObjectForKey:(id)key
{
    return [self setObject:nil forKey:key];
}

- (id)objectForKey:(id)key
{
    NSData *data = [self dataForKey:key];
    if (data) {
        id object = nil;
        if ([key isEqualToString:@"kKeyAESKey"]) {
            object = data;
        } else {
            object = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        return object;
    } else {
        //no value found
        return nil;
    }
}

@end
