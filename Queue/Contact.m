//
//  Contact.m
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "Contact.h"
#import "Queue.h"
#import "Meeting.h"


@implementation Contact

@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic note;
@dynamic addressBookID;
@dynamic meetInterval;
@dynamic oneTimeDueDate;
@dynamic dateAdded;
@dynamic queues;
@dynamic meetings;
@dynamic hasReminderDayOf;
@dynamic hasReminderDayBefore;
@dynamic hasReminderWeekBefore;
@dynamic hasReminderWeekAfter;

#pragma mark - Data Population Methods

static double defaultMeetInterval = 3 * 30.5 * 24 * 60 * 60; /* 1 month ~ 31.5 days */

// -------------------------------------------------------------
// Populate a contact with the data from an address book record
// -------------------------------------------------------------
- (void)populateWithAddressBookRecord:(ABRecordRef)person
{
    ABRecordID recordID = (ABRecordID)ABRecordGetRecordID(person);
    self.addressBookID = [NSNumber numberWithInt:(int)recordID];
    
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    self.firstName = firstName;
    
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    self.lastName = lastName;
    
    NSString* fullName = (__bridge_transfer NSString*)ABRecordCopyCompositeName(person);
    self.fullName = fullName;
    
    [self populateWithDefaultSettings];
}

// -------------------------------------------------------------
// Set default properties for a new contact
// -------------------------------------------------------------
- (void)populateWithDefaultSettings
{
    self.meetInterval = [NSNumber numberWithDouble:defaultMeetInterval];
    self.dateAdded = [NSDate date];
}

#pragma mark - Due Date Methods

// -------------------------------------------------------------
// Determine the contact's due date
// -------------------------------------------------------------
- (NSDate *)dueDate
{
    if (self.oneTimeDueDate)
        return self.oneTimeDueDate;
    return [NSDate dateWithTimeInterval:[self.meetInterval doubleValue] sinceDate:[self lastMeetingDate]];
}


- (NSDate *)lastMeetingDate
{
    NSDate *lastMeetingDate;
    if ([self.meetings count] <= 0) lastMeetingDate = self.dateAdded;
    else lastMeetingDate = [[[self sortedMeetings] objectAtIndex:0] date]; // Sort the meetings by date and grab the most recent date
    return lastMeetingDate;
}

- (double)weeksUntilDue
{
    NSTimeInterval secondsInWeek = 7 * 24 * 60 * 60;
    NSTimeInterval secondsUntilDue = [[self dueDate] timeIntervalSinceDate:[NSDate date]];
    return secondsUntilDue / secondsInWeek;
}

// -------------------------------------------------------------
// Return the contacts meetings sorted by date
// -------------------------------------------------------------
- (NSArray *)sortedMeetings
{
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[dateDescriptor];
    return [[self.meetings allObjects] sortedArrayUsingDescriptors:sortDescriptors];
}










// -------------------------------------------------------------
// Determines whether two contacts are equal
// -------------------------------------------------------------
//- (BOOL)isEqual:(id)object
//{
//    Contact *contact = (Contact *)object;
//    return [contact.addressBookID isEqual:self.addressBookID];
//}
//
//- (NSUInteger)hash {
//    NSUInteger result = 1;
//    NSUInteger prime = 31;
//    //    NSUInteger yesPrime = 1231;
//    //    NSUInteger noPrime = 1237;
//    
//    // Add any object that already has a hash function (NSString)
//    result = prime * result + [self.addressBookID hash];
//    result = prime * result + [self.fullName hash];
//    
//    // Add primitive variables (int)
//    //    result = prime * result + self.primitiveVariable;
//    
//    // Boolean values (BOOL)
//    //    result = prime * result + self.isSelected?yesPrime:noPrime;
//    
//    return result;
//}

@end
