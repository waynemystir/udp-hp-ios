//
//  ListContactsViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/17/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ListContactsViewController.h"
#import "AppDelegate.h"
#import "ContactViewController.h"
#import "UdpClientCallbacks.h"

@interface ListContactsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (nonatomic, strong) ObjcContact *selectedContact;

@end

@implementation ListContactsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _contacts = arrContacts;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    ObjcContact *c = self.contacts[indexPath.row];
    cell.textLabel.text = [c username];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedContact = self.contacts[indexPath.row];
    [self performSegueWithIdentifier:@"sbidSegueToContactVC" sender:self];
//    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    UINavigationController *nc = (UINavigationController *) ad.window.rootViewController;
//    ContactViewController *cvc = [ContactViewController new];
//    cvc.contact = oc;
//    [nc pushViewController:cvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sbidSegueToContactVC"]) {
        ContactViewController *cvc = segue.destinationViewController;
        cvc.contact = self.selectedContact;
    }
}

@end
