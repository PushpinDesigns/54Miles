//
//  MetaMiles.h
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MetaMiles : NSManagedObject

@property (nonatomic, retain) NSNumber * miles;
@property (nonatomic, retain) NSString * end_school;
@property (nonatomic, retain) NSString * beg_school;
@property (nonatomic, retain) NSArray *schoolList;

+(MetaMiles *)schoolNameList;


@end
