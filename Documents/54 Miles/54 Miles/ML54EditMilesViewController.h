//
//  ML54EditMilesViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kCellIdentifier    = @"MyIdentifier";

@interface ML54EditMilesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, strong) NSArray *metaMiles;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end
