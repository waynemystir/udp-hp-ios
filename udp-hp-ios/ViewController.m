//
//  ViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 2/26/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ViewController.h"
#import "udp_dev.h"
#import "udp_client.h"
#import "ObjcContact.h"
#import "ListContactsViewController.h"
#import "AuthN.h"
#include "WESKeyChain.h"
#include "UdpClientCallbacks.h"

@interface ViewController () <UITextViewDelegate>

@end

@implementation ViewController

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [textView resignFirstResponder];
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    vcs = self;
    self.daConsole.delegate = self;
    register_for_wlog(self.daConsole);
    self.arrContacts = [@[] mutableCopy];
}

- (IBAction)tapPing:(id)sender {
    printf("tapPing\n");
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    char *w = send_ping();
    wlog([NSString stringWithUTF8String:w]);
}

- (IBAction)tapHolePunch:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapHolePunch");
}

- (IBAction)tapPingAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapPingAllPeers");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ping_all_peers();
    });
}

- (IBAction)tapSendMessageAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapPingAllPeers");
    char w[32];
    strcpy(w, "hi-de-ho neighbor");
    send_message_to_all_peers(w);
}

- (IBAction)tapListContacts:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapListContacts");
    for (ObjcContact *oc in self.arrContacts) {
        wlog([NSString stringWithFormat:@"Da Contact is %@", [oc username]]);
    }
}

- (IBAction)tapLogOut:(id)sender {
    [AuthN Signout];
    signout();
    UINavigationController *nc = self.navigationController;
    [nc popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSegueListContacts"]) {
        ListContactsViewController *lcvc = segue.destinationViewController;
        lcvc.contacts = self.arrContacts;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
