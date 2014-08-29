//
//  ML54EditMilesViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ML54EditMilesViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, strong) NSArray *userMilesData;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *selectedMonth;
@property (nonatomic, strong) NSString *selectedYear;

@end
