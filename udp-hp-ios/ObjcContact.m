//
//  ObjcContact.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/16/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ObjcContact.h"

@implementation ObjcContact

- (NSString *)username {
    if (!self.theContact || !self.theContact->hn) return nil;
    NSString *str = [NSString stringWithUTF8String:self.theContact->hn->username];
    return str;
}

@end
