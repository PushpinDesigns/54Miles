//
//  ML54AppDelegate.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54AppDelegate.h"
#import "MetaMiles.h"
#import "ML54HomeViewController.h"
#import "UserMiles.h"

@implementation ML54AppDelegate
static NSString *const mileageStore = @"54Miles";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
[self copyDefaultStoreIfNecessary];
    //Copy the preloaded DB to the default path of the application's DB (REQUIRED)
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [paths lastObject];
    NSURL *storeURL = [documentPath URLByAppendingPathComponent:@"Trips_54Miles.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path] ]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Trips_54Miles" ofType:@"sqlite" ]];
        NSError *err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]){
            NSLog(@"Error:  Unable to copy preloaded db.");
        }
    }
    //Setup Magical Record with the CoreData Stack
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Trips_54Miles.sqlite"];
    //Check for user enabled DB Deletion
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"deleteDatabase"]==YES){
        [UserMiles MR_truncateAll];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        [[NSUserDefaults standardUserDefaults] setValue:NO forKey:@"deleteDatabase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Database should be deleted");
    };
    return YES;
}

- (void)copyDefaultStoreIfNecessary;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:mileageStore];
    //If Expected store doesn't exist, copy the default store
    if (![fileManager fileExistsAtPath:[storeURL path] ])
    {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[mileageStore stringByDeletingPathExtension] ofType:[mileageStore pathExtension]];
        if (defaultStorePath){
            NSError *error;
            BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success){
                NSLog(@"Failed to install default mileage store");
            }
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //Cleanup MagicalRecord (CoreData) :: REQUIRED ::
    [MagicalRecord cleanUp];
    
}




@end
