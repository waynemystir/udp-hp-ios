//
//  SearchUsersDetailViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/8/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "SearchUsersDetailViewController.h"
#import "udp_client.h"
#import "ViewController.h"

@interface SearchUsersDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end

@implementation SearchUsersDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameLabel.text = self.username;
}

- (IBAction)tapAddContact:(id)sender {
    client_request_to_add_contact((char*)[self.username UTF8String]);
    NSArray *vcs = self.navigationController.viewControllers;
    for (UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[ViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)setUsername:(NSString *)username {
    _username = username;
    self.usernameLabel.text = username;
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
