//
//  IncomingCallViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/16/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "IncomingCallViewController.h"
#import "VideoCallViewController.h"

@interface IncomingCallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation IncomingCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)tapAnswer:(id)sender {
    [self performSegueWithIdentifier:@"sbidSegueIncomingToVideoVC" sender:self];
}

- (IBAction)tapDecline:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"sbidSegueIncomingToVideoVC"]) {
        VideoCallViewController *vcvc = segue.destinationViewController;
        vcvc.serverHostUrl = self.videoUrl;
        vcvc.roomName = self.roomId;
    }
}


@end
