//
//  SearchUsersViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/4/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "SearchUsersDetailViewController.h"
#import "udp_client.h"

static SearchUsersViewController *suvc;

void username_results(char search_results[MAX_SEARCH_RESULTS][MAX_CHARS_USERNAME], int number_of_search_results) {
    [suvc.tableData removeAllObjects];
    for (int j = 0; j < number_of_search_results; j++) {
        printf("USERNAME_RESULTS **************** (%s)\n", search_results[j]);
        NSString *s = [NSString stringWithUTF8String:search_results[j]];
        [suvc.tableData addObject:s];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [suvc.searchResultsTableview reloadData];
    });
}

@interface SearchUsersViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *searchTextfield;
@property (nonatomic, strong) NSString *selectedUsername;

@end

@implementation SearchUsersViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _tableData = [@[] mutableCopy];
        suvc = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchTextfield.delegate = self;
    self.searchResultsTableview.dataSource = self;
    self.searchResultsTableview.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    search_username([newString UTF8String], username_results);
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    NSString *s = self.tableData[indexPath.row];
    cell.textLabel.text = s;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedUsername = self.tableData[indexPath.row];
    [self performSegueWithIdentifier: @"sbidSegueSearchUsersDetailVC" sender: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"sbidSegueSearchUsersDetailVC"]) {
        SearchUsersDetailViewController *sudvc = segue.destinationViewController;
        sudvc.username = self.selectedUsername;
    }
}


@end
