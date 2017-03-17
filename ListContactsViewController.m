//
//  ListContactsViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/17/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ListContactsViewController.h"
#import "ObjcContact.h"
#import "AppDelegate.h"
#import "ContactViewController.h"

@interface ListContactsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@end

@implementation ListContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    // Do any additional setup after loading the view.
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
    ObjcContact *oc = self.contacts[indexPath.row];
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UINavigationController *nc = (UINavigationController *) ad.window.rootViewController;
    ContactViewController *cvc = [ContactViewController new];
    cvc.contact = oc;
    [nc pushViewController:cvc animated:YES];
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
