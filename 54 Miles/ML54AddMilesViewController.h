//
//  ML54AddMilesViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/8/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ML54AddMilesViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>;
@property (strong, nonatomic) IBOutlet UILabel *begSchoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *endSchoolLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *tripPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *milesLabel;
@property (strong, nonatomic) IBOutlet UIButton *trackMilesButton;
@property (strong, nonatomic) NSArray *schoolArray1;
@property (strong, nonatomic) NSArray *schoolArray2;


- (IBAction)trackMilesButton:(id)sender;
- (NSArray *)getMileage;



@end
