//
//  ML54EditMilesSelectorViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ML54EditMilesSelectorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *monthPicker;
@property (weak, nonatomic) IBOutlet UIButton *editMilesbutton;

- (IBAction)editMilesButton:(id)sender;

@end
