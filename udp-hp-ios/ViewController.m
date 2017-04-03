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
#include "UdpClientCallbacks.h"

void logsCallback(NSString *newLog, NSString *allLogs) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [vcs.daConsole setText:allLogs];
        NSRange bottom = NSMakeRange(vcs.daConsole.text.length - 1, 1);
        [vcs.daConsole scrollRangeToVisible:bottom];
    });
}

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
    NSString *wlogs = addWlogCallback(logsCallback);
    self.daConsole.text = wlogs;
    NSRange bottom = NSMakeRange(self.daConsole.text.length - 1, 1);
    [self.daConsole scrollRangeToVisible:bottom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)tapPing:(id)sender {
    printf("tapPing\n");
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    char *w = send_ping();
    wlog2(w);
}

- (IBAction)tapHolePunch:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog2("tapHolePunch");
}

- (IBAction)tapPingAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog2("tapPingAllPeers");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ping_all_peers();
    });
}

- (IBAction)tapSendMessageAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog2("tapPingAllPeers");
    char w[32];
    strcpy(w, "hi-de-ho neighbor");
    send_message_to_all_peers(w);
}

- (IBAction)tapListContacts:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog2("tapListContacts");
    for (ObjcContact *oc in arrContacts) {
        char w[256];
        sprintf(w, "Da Contact is %s", [[oc username] UTF8String]);
        wlog2(w);
    }
}

- (IBAction)tapLogOut:(id)sender {
    [AuthN Signout];
    signout();
    UINavigationController *nc = self.navigationController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"sbidLoginVC"];
    NSMutableArray *allViewControllers = [nc.viewControllers mutableCopy];
    [allViewControllers insertObject:rvc atIndex:0];
    [nc setViewControllers:allViewControllers];
    [nc popToViewController:rvc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSegueListContacts"]) {
        ListContactsViewController *lcvc = segue.destinationViewController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
