//
//  LoginViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/31/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "udp_client.h"
#import "AuthN.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.usernameTextfield becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextfield) {
        [self.passwordTextfield becomeFirstResponder];
    } else if (textField == self.passwordTextfield) {
        if ([self.usernameTextfield.text length] && [self.passwordTextfield.text length]) {
            send_user(NODE_USER_STATUS_EXISTING_USER,
                      (char*)[self.usernameTextfield.text UTF8String],
                      (char*)[self.passwordTextfield.text UTF8String]);
            UINavigationController *nc = self.navigationController;
            [nc popViewControllerAnimated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [nc pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"sbidMainVC"] animated:YES];
        }
    }
    return YES;
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
