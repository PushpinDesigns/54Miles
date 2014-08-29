//
//  ML54tabbar.m
//  54 Miles
//
//  Created by Chris Goodwin on 2/28/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54tabbar.h"

@interface ML54tabbar ()

@end

@implementation ML54tabbar

- (id) init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
