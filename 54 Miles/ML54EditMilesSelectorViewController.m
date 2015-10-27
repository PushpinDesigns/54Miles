//
//  ML54EditMilesSelectorViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//
#import "ML54EditMilesSelectorViewController.h"
#import "ML54EditMilesViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ML54EditMilesSelectorViewController ()
@end
@implementation ML54EditMilesSelectorViewController
{
    NSArray *monthArray;
    NSMutableArray *yearArray;
    NSString *selectedMonthForSegue;
    NSString *selectedYearForSegue;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _editMilesbutton.layer.cornerRadius = 13;
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    _editMilesPicker.delegate = self;
    _editMilesPicker.dataSource = self;
    //Month Array of all months
    monthArray = [[NSMutableArray alloc]init];
    monthArray = [df monthSymbols];
    int i = 0;
    while (i < [monthArray count]) {
    //NSLog(@"month array: %@", [monthArray objectAtIndex:i]);
        i++;
    }
    //Get Current Month
    [df setDateFormat:@"MMMM"];
    NSString *currentMonth = [NSString stringWithFormat:@"%@", [df stringFromDate:date]];
    //NSLog(@"current month: %@", currentMonth);
    NSUInteger currentMonthIndex = [monthArray indexOfObject:currentMonth];
    //NSLog(@"Current month index: %d",currentMonthIndex);
    [_editMilesPicker selectRow:currentMonthIndex inComponent:0 animated:YES];
    //Initialize our yearArray
    yearArray = [[NSMutableArray alloc]init];
    //Get Last Year
    [dateComponents setYear:-1];
    NSDate *lastYearDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    [df setDateFormat:@"yyyy"];
    NSString *lastYear = [NSString stringWithFormat:@"%@", [df stringFromDate:lastYearDate]];
    [yearArray addObject:lastYear];
    //Current Year
    [df setDateFormat:@"yyyy"];
    NSString *currentYear = [NSString stringWithFormat:@"%@", [df stringFromDate:date]];
    [yearArray addObject:currentYear];
    //Get Next Year
    [dateComponents setYear:+1];
    NSDate *nextYearDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    [df setDateFormat:@"yyyy"];
    NSString *nextYear = [NSString stringWithFormat:@"%@", [df stringFromDate:nextYearDate]];
    [yearArray addObject:nextYear];
    //Reload the components because we've added things to our arrays
    [_editMilesPicker reloadAllComponents];
    //Set the picker component to the current year
    NSUInteger currentYearIndex = [yearArray indexOfObject:currentYear];
    [_editMilesPicker selectRow:currentYearIndex inComponent:1 animated:YES];
    //Set the variables for the tableview segue
    selectedMonthForSegue = [monthArray objectAtIndex:currentMonthIndex];
    selectedYearForSegue = [yearArray objectAtIndex:currentYearIndex];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editMilesButton:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
}
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 2;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_editMilesPicker){
        if (component == 0){
            return [monthArray count];
        }
        if (component == 1){
            return [yearArray count];
        } else {
            return 0;
        }
    }
    return 0;
}

// Title for Row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_editMilesPicker){
        if (component == 0){
            //Set label text
            return [monthArray objectAtIndex:row];
        }
        if (component == 1){
            return [yearArray objectAtIndex:row];
        } else {
            return 0;
        }
    }
    return 0;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_editMilesPicker){
        if (component == 0){            
            selectedMonthForSegue = [monthArray objectAtIndex:row];
        }
        if (component == 1){
            selectedYearForSegue = [yearArray objectAtIndex:row];
        }
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editMilesSegue"]){
        ML54EditMilesViewController *destViewController = segue.destinationViewController;
        destViewController.selectedMonth = selectedMonthForSegue;
        destViewController.selectedYear = selectedYearForSegue;
    }
}

@end
