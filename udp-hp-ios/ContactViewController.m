//
//  ContactViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/17/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ContactViewController.h"
#import "udp_client.h"

@interface ContactViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *contactUsernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatHistoryTextView;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contactUsernameLabel.text = [self.contact username];
    self.messageTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *msgText = textField.text;
    send_message_to_contact(self.contact.theContact, [msgText UTF8String]);
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
