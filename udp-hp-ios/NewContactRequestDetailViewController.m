//
//  NewContactRequestDetailViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/9/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "NewContactRequestDetailViewController.h"
#import "udp_client.h"

@interface NewContactRequestDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation NewContactRequestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameLabel.text = self.username;
}

- (IBAction)tapAccept:(id)sender {
    accept_contact_request((char*)[self.username UTF8String]);
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)tapDecline:(id)sender {
    decline_contact_request((char*)[self.username UTF8String]);
    [[self navigationController] popViewControllerAnimated:YES];
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
