//
//  ML54EditTripViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 3/11/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ML54EditTripViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

//SegueData
@property (nonatomic, strong) NSString *begSchool;
@property (nonatomic, strong) NSString *endSchool;
@property (nonatomic, strong) NSDate *drivenDate;
@property (strong, nonatomic) IBOutlet UIPickerView *tripPicker;
@property (strong, nonatomic) IBOutlet UILabel *begSchoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *endSchoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *milesLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *updateTripButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteTripButton;
- (IBAction)updateTrip:(id)sender;
- (IBAction)deleteTrip:(id)sender;
@property (strong, nonatomic) NSArray *schoolArray1;
@property (strong, nonatomic) NSArray *schoolArray2;
- (NSArray *)getMileage;


@end
