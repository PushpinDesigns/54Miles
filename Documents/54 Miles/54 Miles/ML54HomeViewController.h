//
//  ML54HomeViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ML54UserProfileViewController;

@interface ML54HomeViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@property (strong, nonatomic) IBOutlet UILabel *progName;
@property (strong, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UITableView *recentMilesTable;

@end
