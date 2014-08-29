//
//  ML54UserProfileViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/27/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ML54UserProfileViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullName;
@property (weak, nonatomic) IBOutlet UITextField *employeeID;
@property (weak, nonatomic) IBOutlet UITextField *homeAddress;
@property (strong, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UILabel *optionalRequest;
@property (strong, nonatomic) IBOutlet UIPickerView *schoolPicker;
@property (strong,nonatomic) NSArray *schoolList;
@property (weak, nonatomic) IBOutlet UIButton *saveProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *schoolSelected;

- (IBAction)saveProfileButton:(id)sender;
- (IBAction)textFieldReturn:(id)sender;

@end
