//
//  ML54UserProfileViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/27/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54UserProfileViewController.h"
#import "MetaMiles.h"
#import <QuartzCore/QuartzCore.h>

@interface ML54UserProfileViewController ()

@end

NSArray *fetchedSchools;
NSMutableArray *schoolNames;
NSString *selectedSchool;
MetaMiles *school;

@implementation ML54UserProfileViewController
@synthesize schoolPicker;

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
    //Set self as delegate for name field and see if the user has entered data
    _fullName.delegate = self;
    //set self as delegate for picker
    schoolPicker.delegate = self;
    //Set size of UIPickerView
    schoolPicker.transform = CGAffineTransformMakeScale(0.65, 0.65);
    //Call method to get array of school names (reusable)
    MetaMiles *model = [MetaMiles schoolNameList];
    _schoolList = (NSArray *)model;
    //****LOAD USER DATA IF AVAILABLE****//
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"profileSetup"]==0){
    } else {
        _fullName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"fullName"];
        _employeeID.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"employeeID"];
        _homeAddress.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeAddress"];
        _userEmail.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
        //Set the school picker
        NSString *lastSelectedSchool =[[NSUserDefaults standardUserDefaults] objectForKey:@"baseSchool"];
        NSLog(@"Last Selected School from defaults: %@",lastSelectedSchool);  //(null)
        NSUInteger currentIndex = [_schoolList indexOfObject:lastSelectedSchool];
        NSLog(@"Integer of school: %lu", (unsigned long)currentIndex);
        if (lastSelectedSchool == NULL){
            [schoolPicker selectRow:0 inComponent:0 animated:YES];
        } else {
            [schoolPicker selectRow:currentIndex inComponent:0 animated:YES];
        }
    }
    //****END LOAD USER DATA****//
    //Load the view
    [super viewDidLoad];
    
    _saveProfileButton.layer.cornerRadius = 13;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//****PICKERVIEW METHODS****//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;// or the number of vertical "columns" the picker will show...
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (_schoolList != nil) {
        return [_schoolList count];//this will tell the picker how many rows it has - in this case, the size of your loaded array...
    } else {
    return 0; //Don't return any rows if _schoolList is empty!
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    //you can also write code here to descide what data to return depending on the component ("column")
    if (_schoolList != nil) {
        return [_schoolList objectAtIndex:row];
    }
    
    return nil;//or nil, depending how protective you are
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle selected choice
    selectedSchool = [NSString stringWithFormat:@"%@", [_schoolList objectAtIndex:row]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedSchool forKey:@"baseSchool"];
    [defaults synchronize];
}

//****SAVE USER DATA TO DEFAULT DATA****//
- (IBAction)saveProfileButton:(id)sender {
    if (_fullName.text.length == 0) {
        UIAlertView *nameAlert = [[UIAlertView alloc] initWithTitle:@"Missing Name" message:@"Please enter your name!" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [nameAlert show];
    }
    if (_fullName.text.length > 0) {
    //Clear Keyboard
    [_fullName resignFirstResponder];
    [_employeeID resignFirstResponder];
    [_homeAddress resignFirstResponder];
    [_userEmail resignFirstResponder];
    
    //Create Strings & integer and store them
    NSString *fullName = [_fullName text];
    NSString *employeeID = [_employeeID text];
    NSString *homeAddress = [_homeAddress text];
    NSString *userEmail = [_userEmail text];
    //NSString *baseSchool = selectedSchool;
        
    //Store the data and ensure this view won't show again (unless called)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:fullName forKey:@"fullName"];
    [defaults setObject:employeeID forKey:@"employeeID"];
    [defaults setObject:homeAddress forKey:@"homeAddress"];
    [defaults setObject:userEmail forKey:@"userEmail"];
    //[defaults setObject:baseSchool forKey:@"baseSchool"];

    [defaults setBool:1 forKey:@"profileSetup"];
    
    [defaults synchronize];
    
    //Call to refresh main view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateParent" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}
@end
