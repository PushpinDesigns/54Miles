//
//  ML54EditTripViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 3/11/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54EditTripViewController.h"
#import "UserMiles.h"
#import "MetaMiles.h"
#import "ML54EditMilesViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ML54EditTripViewController ()

@end

@implementation ML54EditTripViewController
{
    NSArray *userTrip;
    UserMiles *currentTrip;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beg_school = %@ AND end_school = %@ AND driven_date = %@", _begSchool, _endSchool, _drivenDate];
    userTrip = [UserMiles MR_findAllWithPredicate:predicate];
    currentTrip = [userTrip objectAtIndex:0];
    
    //set self as delegate for tripPicker
    _tripPicker.delegate = self;
    
    //Set size of tripPicker & datePicker
    _tripPicker.transform = CGAffineTransformMakeScale(0.60, 0.60);
    _datePicker.transform = CGAffineTransformMakeScale(0.60, 0.60);
    
    //Call method to get array of school names (reusable)
    MetaMiles *model = [MetaMiles schoolNameList];
    _schoolArray1 = (NSArray *)model;
    _schoolArray2 = (NSArray *)model;
    
    //Set tripPicker components with appropriate values
    _begSchoolLabel.text = currentTrip.beg_school;
    _endSchoolLabel.text = currentTrip.end_school;
    NSUInteger indexValueComponent0 = [_schoolArray1 indexOfObject:currentTrip.beg_school];
    NSUInteger indexValueComponent1 = [_schoolArray2 indexOfObject:currentTrip.end_school];
    [_tripPicker selectRow:indexValueComponent0 inComponent:0 animated:YES];
    [_tripPicker selectRow:indexValueComponent1 inComponent:1 animated:YES];
    
    //Update the Mileage indicator to display miles between currently selected values
    _milesLabel.text = [NSString stringWithFormat:@"Miles: %@ mi.", currentTrip.miles];
    
    //Set date label to driven date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    _dateLabel.text = [NSString stringWithFormat:@"Date of trip: %@",[dateFormatter stringFromDate:currentTrip.driven_date ]];
    //Set date picker to driven date
    [_datePicker setDate:currentTrip.driven_date animated:YES];
    
    //Set selector method for datePicker so on the value change it updates the date
    [self.datePicker addTarget:self action:@selector(updateLabelForDate:) forControlEvents:UIControlEventValueChanged];
    _updateTripButton.layer.cornerRadius = 13;
    _deleteTripButton.layer.cornerRadius = 13;
}

//****PICKER CONTROLS****//
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    if (_tripPicker){
        return 2;
    }
    return 0;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (_tripPicker){
        if (component == 0){
            return [_schoolArray1 count];
        }
        if (component == 1){
            return [_schoolArray2 count];
        }
    }
    return 0;
}

// Title for Row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_tripPicker) {
        if (component == 0){
            //Set label text
            return [_schoolArray1 objectAtIndex:row];
            _begSchoolLabel.text = [_schoolArray1 objectAtIndex:row];
        }
        if (component == 1){
            return [_schoolArray2 objectAtIndex:row];
            _endSchoolLabel.text = [_schoolArray2 objectAtIndex:row];
        }
    }
    return 0;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_tripPicker) {
        if (component == 0){
            //Get Mileage array
            NSArray *currentMiles = [self getMileage];
            //Update Labels
            _begSchoolLabel.text = [_schoolArray1 objectAtIndex:row];
            MetaMiles *tripMiles = [currentMiles objectAtIndex:0];
            if (tripMiles.miles == NULL){
                _milesLabel.text = @"Miles: 0.0 mi.";
            }else{
                _milesLabel.text = [NSString stringWithFormat:@"Miles: %@ mi.", tripMiles.miles];
            }
        }
        if (component == 1){
            //Get Mileage array
            NSArray *currentMiles = [self getMileage];
            //Update Labels
            _endSchoolLabel.text = [_schoolArray2 objectAtIndex:row];
            MetaMiles *tripMiles = [currentMiles objectAtIndex:0];
            if (tripMiles.miles == NULL){
                _milesLabel.text = @"Miles: 0.0 mi.";
            }else{
                _milesLabel.text = [NSString stringWithFormat:@"Miles: %@ mi.", tripMiles.miles];
            }
        }
        
        
    }
}
//****END PICKER CONTROLS****//


//****DATE PICKER ON CHANGE METHOD****//
- (IBAction)updateLabelForDate:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    _dateLabel.text = [NSString stringWithFormat:@"Date of trip: %@",[dateFormatter stringFromDate:self.datePicker.date ]];
}
//****END DATE PICKER ON CHANGE****//


//****GET MILEAGE METHOD****//
- (NSArray *)getMileage {
    //Update the Mileage indicator to display miles between currently selected values
    NSString *begSchool = [_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:0]];
    NSString *endSchool = [_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:1]];
    NSPredicate *milesFilter = [NSPredicate predicateWithFormat:@"beg_school=%@ AND end_school=%@", begSchool, endSchool];
    NSArray *resultMiles = [MetaMiles MR_findAllWithPredicate:milesFilter];
    if (!resultMiles || ![resultMiles count]) {
        //The first load - this displays appropriately in log letting us know there is currently nothing there
        [_updateTripButton setEnabled:NO];
        //MetaMiles *emptyInstance = [MetaMiles MR_createEntity];
        //resultMiles = [[NSArray alloc]initWithObjects:emptyInstance, nil];
        resultMiles = nil;
    } else {
        [_updateTripButton setEnabled:YES];
    }
    return resultMiles;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Button to track miles
- (IBAction)updateTrip:(id)sender {
    //When button is clicked - update the trip in the User_Miles database!
    //Configure entry data
    currentTrip.beg_school=[_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:0]];
    currentTrip.end_school=[_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:1]];
    
    NSArray *currentMiles = [self getMileage];
    MetaMiles *tripMiles = [currentMiles objectAtIndex:0];
    
    currentTrip.miles= [tripMiles miles];
    currentTrip.driven_date = self.datePicker.date;
    currentTrip.entry_date = [NSDate date];
    //Save the data & reload View
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        //Check to see if there is previous UserMiles entered - if so, set beg_school to appropriate name
        
        //Will not use driven_date in case the user is entering previous dates - use entry_date instead!
        NSArray *tripsSorted = [UserMiles MR_findAllSortedBy:@"entry_date" ascending:YES];
        
        if (!tripsSorted || !tripsSorted.count){
            //if no previous trips have been entered - set the school list to default
            _begSchoolLabel.text = [_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:0]];
        } else {
            UserMiles *lastTrip = [tripsSorted lastObject];
            NSString *preValue = lastTrip.end_school;
            _begSchoolLabel.text = preValue;
            NSUInteger indexValue = [_schoolArray1 indexOfObject:preValue];
            [_tripPicker selectRow:indexValue inComponent:0 animated:YES];
            
        }
        
        //Set end school labels for the second component in the picker
        _endSchoolLabel.text = [_schoolArray2 objectAtIndex:[_tripPicker selectedRowInComponent:1]];
        
        
        //Recalc Miles (should be 0 since the values will be matching)
        //Update the Mileage indicator to display miles between currently selected values
        NSArray *currentMiles = [self getMileage];
        if (currentMiles == NULL){
            //Set the label to display 0 miles originally
            _milesLabel.text = @"Miles: 0.0 mi.";
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view setNeedsDisplay];
    
}
//End button to track miles

- (IBAction)deleteTrip:(id)sender {
    [currentTrip MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
