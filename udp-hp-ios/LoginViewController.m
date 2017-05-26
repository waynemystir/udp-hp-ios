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
#import "Shared.h"
#import "AuthN.h"
#import "UdpClientCallbacks.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    NSNotificationCenter *ndc = [NSNotificationCenter defaultCenter];
    [ndc addObserver:self selector:@selector(letsSendUser:) name:kNotificationReadyToSendUser object:nil];
    [ndc addObserver:self selector:@selector(credsCheckResultNotification:) name:kNotificationCredentialsCheckResult object:nil];
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
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"A problem occurred" message:@"We didn't recognize your username" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aa = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    ;
                }];
                [ac addAction:aa];
                [self presentViewController:ac animated:YES completion:^{
                    ;
                }];
                break;
            }
            case AUTHN_CREDS_CHECK_RESULT_WRONG_PASSWORD: {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"A problem occurred" message:@"You entered the wrong password" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aa = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    ;
                }];
                [ac addAction:aa];
                [self presentViewController:ac animated:YES completion:^{
                    ;
                }];
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
        [self performLogin];
    }
    return YES;
}

- (IBAction)clickLogin:(id)sender {
    [self performLogin];
}

- (void)letsSendUser:(NSNotification*)n {
    send_user(NODE_USER_STATUS_EXISTING_USER,
              (char*)[self.usernameTextfield.text UTF8String],
              (char*)[self.passwordTextfield.text UTF8String]);
}

- (void)performLogin {
    if ([self.usernameTextfield.text length] && [self.passwordTextfield.text length]) {
        NODE_USER_STATUS nus = [AuthN loggedInLastTimeUserName] ? NODE_USER_STATUS_EXISTING_USER : NODE_USER_STATUS_UNKNOWN;
        authn(nus,
              (char*)[self.usernameTextfield.text UTF8String],
              (char*)[self.passwordTextfield.text UTF8String],
              AUTHN_STATUS_RSA_SWAP,
              [AuthN getRSAPubKey],
              [AuthN getRSAPriKey],
              [AuthN getAESKey],
              rsakeypair_generated,
              recd,
              rsa_response,
              aes_key_created,
              aes_response,
              creds_check_result,
              server_connection_failure);
    } else if ([self.usernameTextfield.text length] == 0) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"No username" message:@"Please enter a username" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:^{
            ;
        }];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"No password" message:@"Please enter a password" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:^{
            ;
        }];
    }
}

- (IBAction)clickLogs:(id)sender {
    UINavigationController *nc = self.navigationController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [nc pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"sbidMainVC"] animated:YES];
    
    NSMutableArray *allViewControllers = [nc.viewControllers mutableCopy];
    [allViewControllers removeObjectIdenticalTo: self];
    nc.viewControllers = allViewControllers;
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
