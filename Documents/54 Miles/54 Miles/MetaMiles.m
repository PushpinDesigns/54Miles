//
//  MetaMiles.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "MetaMiles.h"


@implementation MetaMiles

@dynamic miles;
@dynamic end_school;
@dynamic beg_school;
@synthesize schoolList;

+ (NSArray*)schoolNameList {

    NSArray *schoolList;
    MetaMiles *school;
    //Create fetched results controller of data
    NSFetchedResultsController *fetchedSchoolController = [MetaMiles MR_fetchAllSortedBy:@"beg_school" ascending:YES withPredicate:nil groupBy:@"beg_school" delegate:nil];
    [fetchedSchoolController.fetchRequest setReturnsDistinctResults:YES];
    
    //Turn the controller into an array called - fetchedSchools
    NSArray *fetchedSchools = [fetchedSchoolController fetchedObjects];
    
    //Create a set of school names - mutable set (only 1 listing per school)
    NSMutableSet *schoolNames = [[NSMutableSet alloc]init];
    
    //place each school name into the Set
    for (school in fetchedSchools) {
        [schoolNames addObject:school.beg_school];
    }
    //Take the set, turn it into an array (schoolList) and order it by school name
    schoolList = [[schoolNames allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES]]];
    
    return schoolList;
}


@end
