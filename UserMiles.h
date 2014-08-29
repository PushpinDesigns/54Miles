//
//  UserMiles.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/27/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserProfile;

@interface UserMiles : NSManagedObject

@property (nonatomic, retain) NSString * beg_school;
@property (nonatomic, retain) NSDate * driven_date;
@property (nonatomic, retain) NSString * end_school;
@property (nonatomic, retain) NSDate * entry_date;
@property (nonatomic, retain) NSNumber * miles;

@end
