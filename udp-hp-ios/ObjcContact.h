//
//  ObjcContact.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/16/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "udp_client.h"

@interface ObjcContact : NSObject

@property (nonatomic) contact_t *theContact;

- (NSString *)username;

@end
