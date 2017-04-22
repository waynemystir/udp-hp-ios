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
#import "Shared.h"
#import "AppDelegate.h"

void logsCallback(NSString *newLog, NSString *allLogs, LOG_LEVEL log_level) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [vcs.daConsole setText:allLogs];
        NSRange bottom = NSMakeRange(vcs.daConsole.text.length - 1, 1);
        [vcs.daConsole scrollRangeToVisible:bottom];
    });
}

@interface ViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *contactRequestsButton;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewContactRequests:) name:kNotificationAddContactRequest object:nil];
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [textView resignFirstResponder];
    return NO;
}

- (void)handleNewContactRequests:(NSNotification*)notification {
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *w = [notification.userInfo objectForKey:@"username"];
    if (ad.contactRequests.count || ![w isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contactRequestsButton.hidden = NO;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contactRequestsButton.hidden = YES;
        });
    }
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
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (ad.contactRequests.count) {
        self.contactRequestsButton.hidden = NO;
    } else {
        self.contactRequestsButton.hidden = YES;
    }
}

- (IBAction)tapPing:(id)sender {
    printf("tapPing\n");
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    char *w = send_ping();
    wlog2(w, INFO_LOG);
}

- (IBAction)tapSendMessageAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog2("tapPingAllPeers", INFO_LOG);
    char w[32];
    strcpy(w, "hi-de-ho neighbor");
    send_message_to_all_contacts(w);
}

- (IBAction)tapListContacts:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog2("tapListContacts", INFO_LOG);
    for (ObjcContact *oc in arrContacts) {
        char w[256];
        sprintf(w, "Da Contact is %s", [[oc username] UTF8String]);
        wlog2(w, INFO_LOG);
    }
}

- (IBAction)tapLogOut:(id)sender {
    [AuthN Signout];
    signout();
    [AuthN setLoggedInLastTimeUserName:nil];
    authn(NODE_USER_STATUS_UNKNOWN,
          [[AuthN loggedInLastTimeUserName] UTF8String],
          [[AuthN getPasswordForUsername:[AuthN loggedInLastTimeUserName]] UTF8String],
          AUTHN_STATUS_RSA_SWAP,
          [AuthN getRSAPubKey],
          [AuthN getRSAPriKey],
          [AuthN getAESKey],
          pfail_bc,
          rsakeypair_generated,
          recd,
          rsa_response,
          aes_key_created,
          aes_response,
          creds_check_result,
          general);
    UINavigationController *nc = self.navigationController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"sbidLoginVC"];
    NSMutableArray *allViewControllers = [nc.viewControllers mutableCopy];
    [allViewControllers insertObject:rvc atIndex:0];
    [nc setViewControllers:allViewControllers];
    [nc popToViewController:rvc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
