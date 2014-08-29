//
//  ML54AddMilesViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/8/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54AddMilesViewController.h"
#import "MetaMiles.h"
#import "UserMiles.h"


@interface ML54AddMilesViewController ()

@end

NSArray *currentMiles;

ML54AddMilesViewController *milesObject;
MetaMiles *school;

@implementation ML54AddMilesViewController
@synthesize begSchoolLabel, endSchoolLabel;
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
    
    //set self as delegate for tripPicker
    _tripPicker.delegate = self;
    
    //Set size of tripPicker & datePicker
    _tripPicker.transform = CGAffineTransformMakeScale(0.60, 0.60);
    _datePicker.transform = CGAffineTransformMakeScale(0.60, 0.60);
    
    //Call method to get array of school names (reusable)
    MetaMiles *model = [MetaMiles schoolNameList];
    _schoolArray1 = (NSArray *)model;
    _schoolArray2 = (NSArray *)model;
    
    //Set date to current date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    _dateLabel.text = [NSString stringWithFormat:@"Date of trip: %@",[dateFormatter stringFromDate:self.datePicker.date ]];
    
    //Set selector method for datePicker so on the value change it updates the date
    [self.datePicker addTarget:self action:@selector(updateLabelForDate:) forControlEvents:UIControlEventValueChanged];
    
    //Check to see if there is previous UserMiles entered - if so, set beg_school to appropriate name
    //you COULD use driven_date here to get the last trip they drove on for the initial load of the app
    NSArray *tripsSorted = [UserMiles MR_findAllSortedBy:@"entry_date" ascending:YES];
    
    
    // TEST TO SEE THE OBJECTS IN THE ARRAY FROM USER MILES //
    //        if (tripsSorted){
    //            int i;
    //            for (i=0; i<[tripsSorted count]; i++) {
    //                id myArrayElement = [tripsSorted objectAtIndex:i];
    //                NSLog(@"Beg_school: %@ ; End_School: %@ ; Date: %@", [myArrayElement beg_school],[myArrayElement end_school], [myArrayElement entry_date]);
    //            }
    //        }
    
    
    if (!tripsSorted || !tripsSorted.count){
        //if no previous trips have been entered - set the school list to default
        begSchoolLabel.text = [_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:0]];
    } else {
        UserMiles *lastTrip = [tripsSorted lastObject];
        NSString *preValue = lastTrip.end_school;
        begSchoolLabel.text = preValue;
        int indexValue = [_schoolArray1 indexOfObject:preValue];
        [_tripPicker selectRow:indexValue inComponent:0 animated:YES];
        
    }
    
    //Set end school labels for the second component in the picker
    endSchoolLabel.text = [_schoolArray2 objectAtIndex:[_tripPicker selectedRowInComponent:1]];
 
    
    
    [super viewDidLoad];
    
    
    //Update the Mileage indicator to display miles between currently selected values
    NSArray *currentMiles = [self getMileage];
    if (currentMiles == NULL){
        NSLog(@"Current Miles if ran: %@",currentMiles);
        //Set the label to display 0 miles originally
        _milesLabel.text = @"Miles: 0.0 mi.";
    } else {
        MetaMiles *tripMiles = [currentMiles objectAtIndex:0];
        _milesLabel.text = [NSString stringWithFormat:@"Miles: %@ mi.", tripMiles.miles];
    }
    
    
    
    

    

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Button to track miles
- (IBAction)trackMilesButton:(id)sender {
    //When button is clicked - save the trip to the User_Miles database!
    UserMiles *newMilesEntry = [UserMiles MR_createEntity];
    //Configure entry data
    [newMilesEntry setBeg_school:[_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:0]]];
    [newMilesEntry setEnd_school:[_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:1]]];
    NSArray *currentMiles = [self getMileage];
    MetaMiles *tripMiles = [currentMiles objectAtIndex:0];
    [newMilesEntry setMiles:tripMiles.miles];
    [newMilesEntry setDriven_date:self.datePicker.date];
    [newMilesEntry setEntry_date:[NSDate date]];
    //Save the data & reload View
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    
        //Reset the pickerview  **********THIS LOGIC NEEDS WORK**********
        //Check to see if there is previous UserMiles entered - if so, set beg_school to appropriate name
        
        //Will not use driven_date in case the user is entering previous dates - use entry_date instead!
        NSArray *tripsSorted = [UserMiles MR_findAllSortedBy:@"entry_date" ascending:YES];

        
        // TEST TO SEE THE OBJECTS IN THE ARRAY FROM USER MILES //
//        if (tripsSorted){
//            int i;
//            for (i=0; i<[tripsSorted count]; i++) {
//                id myArrayElement = [tripsSorted objectAtIndex:i];
//                NSLog(@"Beg_school: %@ ; End_School: %@ ; Date: %@", [myArrayElement beg_school],[myArrayElement end_school], [myArrayElement entry_date]);
//            }
//        }
        
        
        if (!tripsSorted || !tripsSorted.count){
            //if no previous trips have been entered - set the school list to default
            begSchoolLabel.text = [_schoolArray1 objectAtIndex:[_tripPicker selectedRowInComponent:0]];
        } else {
            UserMiles *lastTrip = [tripsSorted lastObject];
            NSString *preValue = lastTrip.end_school;
            begSchoolLabel.text = preValue;
            int indexValue = [_schoolArray1 indexOfObject:preValue];
            [_tripPicker selectRow:indexValue inComponent:0 animated:YES];
            
        }
        
        //Set end school labels for the second component in the picker
        endSchoolLabel.text = [_schoolArray2 objectAtIndex:[_tripPicker selectedRowInComponent:1]];
        
        
        //Recalc Miles (should be 0 since the values will be matching)
        //Update the Mileage indicator to display miles between currently selected values
        NSArray *currentMiles = [self getMileage];
        if (currentMiles == NULL){
            NSLog(@"Current Miles if ran: %@",currentMiles);
            //Set the label to display 0 miles originally
            _milesLabel.text = @"Miles: 0.0 mi.";
        }
        
        
        NSLog (@"saveInBackground: finished!");
        
    }];
    
    [self.view setNeedsDisplay];
    
}
//End button to track miles


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
        begSchoolLabel.text = [_schoolArray1 objectAtIndex:row];
        }
        if (component == 1){
        return [_schoolArray2 objectAtIndex:row];
        endSchoolLabel.text = [_schoolArray2 objectAtIndex:row];
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
            begSchoolLabel.text = [_schoolArray1 objectAtIndex:row];
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
            endSchoolLabel.text = [_schoolArray2 objectAtIndex:row];
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
        NSLog(@"Empty Array");
        //MetaMiles *emptyInstance = [MetaMiles MR_createEntity];
        //resultMiles = [[NSArray alloc]initWithObjects:emptyInstance, nil];
        resultMiles = nil;
    } else {
        MetaMiles *tripMiles = [resultMiles objectAtIndex:0];
        //This confirms our result miles come out appropriately - they look like this: ("2.1")
        NSLog(@"Our result miles are: %@", tripMiles.miles);
    }
    return resultMiles;
}
//****END GET MILEAGE****//


@end
