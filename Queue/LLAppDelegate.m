//
//  LLAppDelegate.m
//  Queue
//
//  Created by Jeremy Lubin on 5/15/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLAppDelegate.h"
#import <CoreData/CoreData.h>
#import <GoogleMaps/GoogleMaps.h>
#import "LLPullNavigationController.h"
#import "QueuesViewController.h"
#import "Queue.h"
#import "Contact.h"
#import "Contact+LocalNotifications.h"

@implementation LLAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)customizeUserInterfaceElements
{
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bar.png"] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1]];
//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0],
      UITextAttributeFont,
      nil]];
    
    UIImage *backButtonImageNormal = [UIImage imageNamed:@"nav_button_back.png"];
    UIImage *stretchableBackButtonImageNormal = [backButtonImageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
    
    UIImage *backButtonImagePressed = [UIImage imageNamed:@"nav_button_back_pressed.png"];
    UIImage *stretchableBackButtonImagePressed = [backButtonImagePressed resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
    
    UIImage *buttonImageNormal = [UIImage imageNamed:@"nav_button.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    
    UIImage *buttonImagePressed = [UIImage imageNamed:@"nav_button_pressed.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:stretchableBackButtonImageNormal
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:stretchableBackButtonImagePressed
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:stretchableButtonImageNormal
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:stretchableButtonImagePressed
                                            forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self customizeUserInterfaceElements];
    [GMSServices provideAPIKey:@"AIzaSyA9I-EJpd4dZ7SgSFmKkYz-PzxeMCoHaU4"];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
    
    // Cancel any scheduled local notifications
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp cancelAllLocalNotifications];
    
    // Create a table to hold the queue
    QueuesViewController *queueTable = [[QueuesViewController alloc] init];
    queueTable.title = @"My Queues";
    queueTable.managedObjectContext = context;
    
    // Add the table to the nav controller
    LLPullNavigationController *pullController = [[LLPullNavigationController alloc] initWithRootViewController:queueTable];
    self.pullController = pullController;
    
    // Add the nav controller to the window
    self.window.rootViewController = self.pullController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self prepareForApplicationClose];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Cancel any scheduled local notifications
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self prepareForApplicationClose];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Local Notifications Methods

- (void)prepareForApplicationClose
{
    NSArray *queues = [self queues];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self overdueCountForQueues:queues];
    [self scheduleLocalNotificationsForQueues:queues];
    
    [self saveContext];
}

- (NSArray *)queues
{
    // Load all of the Queues from memory
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Queue" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *queues = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (queues == nil) {
        // Handle the error.
    }
    return queues;
}

- (int)overdueCountForQueues:(NSArray *)queues;
{
    int badge = 0;
    
    for (Queue *queue in queues)
    {
        for (Contact *contact in queue.contacts)
        {
            if ([contact isOverdueIncludingSnoozes:YES])
                badge++;
        }
    }
    
    return badge;
}

- (void)scheduleLocalNotificationsForQueues:(NSArray *)queues
{    
    // Iterate through each contact
    // and generate his/her local notifications
    NSMutableArray *notifications = [NSMutableArray arrayWithCapacity:64];
    for (Queue *queue in queues)
    {
        for (Contact *contact in queue.contacts)
            [notifications addObjectsFromArray:[contact generateLocalNotifications]];
    }
    
    // Pick out just the day of overdue notifications
    // and schedule the rest
    NSMutableDictionary *dayOfNotifications = [NSMutableDictionary dictionaryWithCapacity:64];
    for (UILocalNotification *notification in notifications)
    {
        if ([[notification.userInfo objectForKey:@"type"] intValue] == ContactLocalNotificationTypeDayOf)
            [dayOfNotifications setObject:notification forKey:notification.fireDate];
        else
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    // Sort the day of notifications by due date
    NSArray *sortedDayOfNotificationKeys = [[dayOfNotifications allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *sortedDayOfNotifications = [NSMutableArray arrayWithCapacity:[sortedDayOfNotificationKeys count]];
    for (id key in sortedDayOfNotificationKeys)
        [sortedDayOfNotifications addObject:[dayOfNotifications objectForKey:key]];
    
    // Set the badge count change appropriately
    int badgeCount = [self overdueCountForQueues:queues];
    for (UILocalNotification *notification in sortedDayOfNotifications)
    {
        badgeCount++;
        notification.applicationIconBadgeNumber = badgeCount;
        
        // Schedule the day of notification with the system
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Queue" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Queue.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
