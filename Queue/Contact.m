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
#import "UIImage+Resize.h"

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
//@dynamic image;
//@dynamic imageType;

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
    self.hasReminderDayBefore = [NSNumber numberWithBool:YES];
    self.hasReminderDayOf = [NSNumber numberWithBool:YES];
    self.hasReminderWeekBefore = [NSNumber numberWithBool:NO];
    self.hasReminderWeekAfter = [NSNumber numberWithBool:NO];
}

// -------------------------------------------------------------
// Fetch and return a contact's image lazily
// -------------------------------------------------------------
- (UIImage *)image
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.addressBookID intValue]);
    NSData *imageData = (__bridge NSData *)ABPersonCopyImageData(person);
    return [UIImage imageWithData:imageData];
}

// -------------------------------------------------------------
// Fetch and return a contact's thumbnail image lazily
// -------------------------------------------------------------
- (UIImage *)thumbnail
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.addressBookID intValue]);
    NSData *imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
    return [UIImage imageWithData:imageData];
}

// -------------------------------------------------------------
// Return the contact's queue name
// NOTE: This method assumes that the contact only has one queue
// -------------------------------------------------------------
- (NSString *)queueName
{
    return [[[self.queues allObjects] objectAtIndex:0] name];
}

// -------------------------------------------------------------
// Return a thumbnail of the contact image at the given size
// -------------------------------------------------------------
- (UIImage *)thumbnailWithSize:(CGFloat)size cornerRadius:(CGFloat)radius
{
    return [[self image] thumbnailImage:104
               transparentBorder:0
                    cornerRadius:8
            interpolationQuality:kCGInterpolationHigh];
}

#pragma mark - Due Date Methods

// -------------------------------------------------------------
// Determine whether the contact is currently overdue
// -------------------------------------------------------------
- (BOOL)isOverdueIncludingSnoozes:(BOOL)snoozes
{    
    NSDate *deadline = [self dueDateIncludingSnoozes:snoozes];
    NSDate *today = [NSDate date];
    
    switch ([today compare:deadline])
    {
        case NSOrderedAscending:
            return NO;
        case NSOrderedDescending:
            return YES;
        case NSOrderedSame:
            return YES;
    }
}

// -------------------------------------------------------------
// Determine the contact's due date
// -------------------------------------------------------------
- (NSDate *)dueDateIncludingSnoozes:(BOOL)snoozes
{
    if (self.oneTimeDueDate)
        return self.oneTimeDueDate;
    return [NSDate dateWithTimeInterval:[self.meetInterval doubleValue] sinceDate:[self lastMeetingDateIncludingSnoozes:snoozes]];
}


- (NSDate *)lastMeetingDateIncludingSnoozes:(BOOL)snoozes
{
    NSDate *lastMeetingDate;
    if ([self.meetings count] <= 0) lastMeetingDate = self.dateAdded;
    else lastMeetingDate = [[[self sortedMeetings] objectAtIndex:0] date]; // Sort the meetings by date and grab the most recent date
    return lastMeetingDate;
    
    // Find the last meeting that isn't a snooze
//    else
//    {
//        for (Meeting *meeting in [self sortedMeetings])
//        {
//            if (![meeting.method isEqualToString:@"snooze"] || snoozes)
//                return [meeting date];
//        }
//    }
//    return self.dateAdded;
}

- (double)weeksUntilDue
{
    NSTimeInterval secondsInWeek = 7 * 24 * 60 * 60;
    NSTimeInterval secondsUntilDue = [[self dueDateIncludingSnoozes:NO] timeIntervalSinceDate:[NSDate date]];
    return secondsUntilDue / secondsInWeek;
}

// -------------------------------------------------------------
// Return a text form of the meet interval
// e.g. "3 months"
// -------------------------------------------------------------
- (NSString *)meetIntervalText
{
    if (self.meetInterval)
    {
		int year = 31536000;
		int month = 2635200;
		int week = 604800;
		int day = 86400;
		
		int display = [self.meetInterval intValue];
		int remainderYear = (display % year);
		int remainderMonth = (display % month);
		int remainderWeek = (display % week);
		int remainderDay = (display % day);
		
		int divideMonth = (display / month);
		int divideWeek = (display / week);
		int divideDay = (display / day);
		
		if (remainderYear == 0)
			return @"1 year";
        
		else if (remainderMonth == 0)
        {
			if (divideMonth == 1)
				return @"1 month";
			else
				return [NSString stringWithFormat:@"%d months", divideMonth];
        }
        
        else if (remainderWeek == 0)
        {
            if (divideWeek == 1)
                return @"1 week";
            else
                return [NSString stringWithFormat:@"%d weeks", divideWeek];
        }
        
        else if (remainderDay == 0)
        {
            if (divideDay == 1)
                return @"1 day";
            else
                return [NSString stringWithFormat:@"%d days", divideDay];
        }
	}
    
	return @"never";
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
