//
//  Contact+Contact_LocalNotifications.m
//  Queue
//
//  Created by Jeremy Lubin on 7/16/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "Contact+LocalNotifications.h"

@implementation Contact (LocalNotifications)

// -------------------------------------------------------------
// Generate and return all the local notifications for the contact
//
// NOTE: This does not schedule the notifications with the system
// nor does it set the badge count. The badge count can only be
// set once all of the app's notifications have been generated.
// -------------------------------------------------------------
- (NSArray *)generateLocalNotifications
{
    NSMutableArray *notifications = [NSMutableArray arrayWithCapacity:4];
    
    if ([self.hasReminderDayBefore boolValue]
        && [[self dueDateIncludingSnoozes:YES] compare:[NSDate dateWithTimeIntervalSinceNow:(60*60*24)]] == NSOrderedDescending)
        [notifications addObject:[self generateLocationNotificationType:ContactLocalNotificationTypeDayBefore]];
    if ([self.hasReminderDayOf boolValue]
        && [[self dueDateIncludingSnoozes:YES] compare:[NSDate date]] == NSOrderedDescending)
        [notifications addObject:[self generateLocationNotificationType:ContactLocalNotificationTypeDayOf]];
    if ([self.hasReminderWeekAfter boolValue]
        && [[self dueDateIncludingSnoozes:YES] compare:[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*7)]] == NSOrderedDescending)
        [notifications addObject:[self generateLocationNotificationType:ContactLocalNotificationTypeWeekAfter]];
    if ([self.hasReminderWeekBefore boolValue]
        && [[self dueDateIncludingSnoozes:YES] compare:[NSDate dateWithTimeIntervalSinceNow:(60*60*24*7)]] == NSOrderedDescending)
        [notifications addObject:[self generateLocationNotificationType:ContactLocalNotificationTypeWeekBefore]];
    
    return notifications;
}


// -------------------------------------------------------------
// Generate and return a local notifications of the given type
//
// NOTE: This does not schedule the notifications with the system
// nor does it set the badge count. The badge count can only be
// set once all of the app's notifications have been generated.
// -------------------------------------------------------------
- (UILocalNotification *)generateLocationNotificationType:(ContactLocalNotificationType)type
{
    // Prepare the info object for the notification
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:4];
    [info setObject:self.firstName forKey:@"name"];
    [info setObject:[self queueName] forKey:@"queue"];
    [info setObject:self.addressBookID forKey:@"id"];
    [info setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    // Prepare the notification object
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertAction = @"View";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = info;
    
    
    // Set the notification's fire date
    switch (type) {
        case ContactLocalNotificationTypeDayBefore:
            notification.fireDate = [NSDate dateWithTimeInterval:-(60*60*24) sinceDate:[self dueDateIncludingSnoozes:YES]];
            notification.alertBody = [NSString stringWithFormat:@"%@ is due tomorrow on your %@ queue", self.firstName, [self queueName]];
            break;
            
        case ContactLocalNotificationTypeDayOf:
            notification.fireDate = [self dueDateIncludingSnoozes:YES];
            notification.alertBody = [NSString stringWithFormat:@"%@ is due today on your %@ queue", self.firstName, [self queueName]];
            break;
            
        case ContactLocalNotificationTypeWeekAfter:
            notification.fireDate = [NSDate dateWithTimeInterval:(60*60*24*7) sinceDate:[self dueDateIncludingSnoozes:YES]];
            notification.alertBody = [NSString stringWithFormat:@"%@ is 1 week overdue on your %@ queue", self.firstName, [self queueName]];
            break;
            
        case ContactLocalNotificationTypeWeekBefore:
            notification.fireDate = [NSDate dateWithTimeInterval:-(60*60*24*7) sinceDate:[self dueDateIncludingSnoozes:YES]];
            notification.alertBody = [NSString stringWithFormat:@"%@ is due in 1 week on your %@ queue", self.firstName, [self queueName]];
            break;
            
        default:
            break;
    }
    
    return notification;
}

@end
