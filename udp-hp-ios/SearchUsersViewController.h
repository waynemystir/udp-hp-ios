//
//  SearchUsersViewController.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/4/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUsersViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableview;
@property (nonatomic, strong) NSMutableArray<NSString*> *tableData;

@end
