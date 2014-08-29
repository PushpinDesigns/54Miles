//
//  ML54PrintMilesViewController.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ML54PrintMilesViewController : UIViewController <NSFetchedResultsControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *datePicker;
@property (strong, nonatomic) IBOutlet UITextField *userEmailTextField;
@property (strong, nonatomic) IBOutlet UITextField *mileageRateTextField;
@property (strong, nonatomic) IBOutlet UILabel *suggestedMileageLabel;
@property (strong, nonatomic) IBOutlet UIButton *emailMilesButton;
@property (strong, nonatomic) IBOutlet NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet NSManagedObjectContext *context;
- (IBAction)emailMiles:(id)sender;

@end
