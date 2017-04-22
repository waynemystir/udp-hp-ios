//
//  CreateAccountViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/2/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "udp_client.h"
#import "Shared.h"

@interface CreateAccountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.usernameTextfield becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(credsCheckResultNotification:) name:kNotificationCredentialsCheckResult object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)credsCheckResultNotification:(NSNotification *)notification {
    NSNumber *obj = [notification object];
    if (![obj isKindOfClass:[NSNumber class]]) return;
    AUTHN_CREDS_CHECK_RESULT cr = [obj intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (cr) {
            case AUTHN_CREDS_CHECK_RESULT_GOOD: {
                UINavigationController *nc = self.navigationController;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                [nc pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"sbidMainVC"] animated:YES];
                
                NSMutableArray *allViewControllers = [nc.viewControllers mutableCopy];
                [allViewControllers removeObjectIdenticalTo: self];
                nc.viewControllers = allViewControllers;
                break;
            }
            case AUTHN_CREDS_CHECK_RESULT_USER_NOT_FOUND: {
                break;
            }
            case AUTHN_CREDS_CHECK_RESULT_WRONG_PASSWORD: {
                break;
            }
            case AUTHN_CREDS_CHECK_RESULT_MISC_ERROR: {
                break;
            }
                
            default:
                break;
        }
    });
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
            send_user(NODE_USER_STATUS_NEW_USER,
                      (char*)[self.usernameTextfield.text UTF8String],
                      (char*)[self.passwordTextfield.text UTF8String]);
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
