//
//  ListContactsViewController.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/17/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjcContact.h"

@interface ListContactsViewController : UIViewController

@property (nonatomic, strong) NSArray<ObjcContact*> *contacts;

@end
