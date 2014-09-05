//
//  ML54HomeViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54HomeViewController.h"
#import "ML54AddMilesViewController.h"
#import "ML54UserProfileViewController.h"
#import "ML54AppDelegate.h"
#import "UserMiles.h"

@interface ML54HomeViewController ()

@end

@implementation ML54HomeViewController
{
    NSArray *trips;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    trips = [UserMiles MR_findAllSortedBy:@"driven_date" ascending:YES];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"driven_date" ascending:YES];
    if (trips != nil){
    trips = [trips sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    //reverse the array so the 5 most recent are the first 5 listed
    trips = [[trips reverseObjectEnumerator] allObjects];
    } else {
    }
    [self.recentMilesTable reloadData];
}
- (void)viewDidLoad
{
    //Load the View
    [super viewDidLoad];
    //Get User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fullName = [defaults objectForKey:@"fullName"];
    //Set the Welcome
    NSString *welcome = [NSString stringWithFormat:@"Hello, %@", fullName];
    //Update UI with Welcome
    self.userName.text = welcome;
    self.recentMilesTable.dataSource = self;
    trips = [UserMiles MR_findAllSortedBy:@"driven_date" ascending:YES];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"driven_date" ascending:YES];
    trips = [trips sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    //reverse the array so the 5 most recent are the first 5 listed
    trips = [[trips reverseObjectEnumerator] allObjects];
    [self.recentMilesTable reloadData];
    //Refresh the view if coming from the profile view (first run of App)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView:) name:@"updateParent" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)profileViewShow {
    ML54UserProfileViewController *profileView = [[ML54UserProfileViewController alloc]init];
    [self.view addSubview:profileView.view];
    [self addChildViewController:profileView];
    [self presentViewController:profileView animated:YES completion:nil];
}

- (void)reloadView:(NSNotification *)notification {
    //Reloads the view
    [self viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    //If the profile has not been setup - go to the profile page for intial setup (Modal segue)
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"profileSetup"]==0){
        UIStoryboard *storyboard = self.storyboard;
        ML54UserProfileViewController *profileView = [storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
        [self presentViewController:profileView animated:YES completion:NULL];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([trips count]<5)
    {
        return [trips count];
    } else {
        return 5;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:MyIdentifier];
    }
    UserMiles *cellInfo = [self milesAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@", cellInfo.beg_school, cellInfo.end_school];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    dateFormat.dateFormat = @"MM/dd/yyyy";
    NSString *date = [dateFormat stringFromDate:cellInfo.driven_date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", date];
    return cell;
}

-(UserMiles *) milesAtIndex: (NSInteger) index
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"driven_date" ascending:NO];
    return [[trips sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] objectAtIndex:index];
}



@end
