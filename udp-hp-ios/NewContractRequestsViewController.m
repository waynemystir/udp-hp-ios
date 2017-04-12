//
//  NewContractRequestsViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/8/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "NewContractRequestsViewController.h"
#import "NewContactRequestDetailViewController.h"
#import "Shared.h"
#import "AppDelegate.h"

@interface NewContractRequestsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString*> *tableData;
@property (nonatomic, strong) NSString *selectedUsername;

@end

@implementation NewContractRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.tableData = ad.contactRequests;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewContactRequestToList:) name:kNotificationAddContactRequest object:nil];
}

- (void)addNewContactRequestToList:(NSNotification*)notification {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *w = self.tableData[indexPath.row];
    UITableViewCell *c = [UITableViewCell new];
    c.textLabel.text = w;
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedUsername = self.tableData[indexPath.row];
    [self performSegueWithIdentifier: @"sbidSegueNewContactDetailVC" sender: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sbidSegueNewContactDetailVC"]) {
        NewContactRequestDetailViewController *ncrdvc = segue.destinationViewController;
        ncrdvc.username = self.selectedUsername;
    }
}


@end
