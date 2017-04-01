//
//  ViewController.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 2/26/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, atomic) IBOutlet UITextView *daConsole;
@property (nonatomic, strong) NSMutableArray *arrContacts;

@end

static ViewController *vcs;

