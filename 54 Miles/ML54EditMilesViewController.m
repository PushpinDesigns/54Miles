//
//  ML54EditMilesViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54EditMilesViewController.h"
#import "ML54AppDelegate.h"
#import "MetaMiles.h"
#import "UserMiles.h"
#import "ML54EditTripViewController.h"

@interface ML54EditMilesViewController  ()
@end

@implementation ML54EditMilesViewController
{
    NSArray *allTableData;
    NSDate *startOfMonth, *endOfMonth, *drivenDate;
    NSString *begSchool, *endSchool;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    
    self.userMilesData = [NSMutableArray array];
    NSPredicate *monthPredicates = [self predicateToRetrieveMonthTrips];
    _fetchedResultsController = [UserMiles MR_fetchAllSortedBy:@"driven_date" ascending:YES withPredicate:monthPredicates groupBy:nil delegate:self];
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    allTableData = [_fetchedResultsController fetchedObjects];
    //Reverse Data to match what is being displayed
    allTableData = [[allTableData reverseObjectEnumerator] allObjects];
    NSLog(@"Edit Miles Table Data Order: %@",allTableData);
    
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userMilesData = [NSMutableArray array];
    NSPredicate *monthPredicates = [self predicateToRetrieveMonthTrips];
    _fetchedResultsController = [UserMiles MR_fetchAllSortedBy:@"driven_date" ascending:YES withPredicate:monthPredicates groupBy:nil delegate:self];
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    allTableData = [_fetchedResultsController fetchedObjects];

    //HANDLE IF THE ARRAY IS EMPTY!!!!!!!!//
    if (!allTableData) {
    }
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	return [allTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableID = @"SimpleTable";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableID];
	}
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UserMiles *cellInfo = allTableData[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@", cellInfo.beg_school, cellInfo.end_school];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    dateFormat.dateFormat = @"MM/dd/yyyy";
    NSString *date = [dateFormat stringFromDate:cellInfo.driven_date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", date];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editTrip"]){
        ML54EditTripViewController *vc = segue.destinationViewController;
        vc.begSchool = begSchool;
        vc.endSchool = endSchool;
        vc.drivenDate = drivenDate;
    }
     //Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserMiles *cellDetails = allTableData[indexPath.row];
    begSchool = [cellDetails beg_school];
    endSchool = [cellDetails end_school];
    drivenDate = [cellDetails driven_date];
    [self performSegueWithIdentifier:@"editTrip" sender:self];
}

- (NSPredicate *)predicateToRetrieveMonthTrips {
    //Standard date format
    //YYYY-MM-dd HH:mm:ss
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"MMMM"];
    NSDate *numMonth = [df dateFromString:_selectedMonth];
    [df setDateFormat:@"MM"];
    NSString *properIntMonth = [NSString stringWithFormat:@"%@", [df stringFromDate:numMonth]];
    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *begMonthDateString = [NSString stringWithFormat:@"%@-%@-01 00:00:00", _selectedYear, properIntMonth];
    startOfMonth = [df dateFromString:begMonthDateString];
    [dateComponents setMonth:+1];
    NSDate *nextMonth = [calendar dateByAddingComponents:dateComponents toDate:startOfMonth options:0];
    NSString *endMonthDateString = [df stringFromDate:nextMonth];
    endOfMonth = [df dateFromString:endMonthDateString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"driven_date >= %@ AND driven_date < %@ AND driven_date != null", startOfMonth, endOfMonth];
    return predicate;
}
@end
