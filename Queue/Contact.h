//
//  Contact.h
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class Queue;
@class Meeting;

typedef enum {
    ContactImageTypeAddressBook,
    ContactImageTypeFacebook,
    ContactImageTypeLinkedIn,
    ContactImageTypeGoogle
} ContactImageType;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * addressBookID;
@property (nonatomic, retain) NSNumber * meetInterval;
@property (nonatomic, retain) NSDate   * oneTimeDueDate;
@property (nonatomic, retain) NSDate   * dateAdded;
@property (nonatomic, retain) NSSet *queues;
@property (nonatomic, retain) NSSet *meetings;
@property (nonatomic, retain) NSNumber * hasReminderDayOf;
@property (nonatomic, retain) NSNumber * hasReminderDayBefore;
@property (nonatomic, retain) NSNumber * hasReminderWeekBefore;
@property (nonatomic, retain) NSNumber * hasReminderWeekAfter;
//@property (nonatomic, retain) UIImage  * image;
//@property (nonatomic)         int32_t    imageType;

- (void)populateWithAddressBookRecord:(ABRecordRef)person;
- (NSDate *)dueDateIncludingSnoozes:(BOOL)snoozes;
- (double)weeksUntilDue;
- (NSArray *)sortedMeetings;
- (UIImage *)image;
- (UIImage *)thumbnail;
- (UIImage *)thumbnailWithSize:(CGFloat)size cornerRadius:(CGFloat)radius;

@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addQueuesObject:(Queue *)value;
- (void)removeQueuesObject:(Queue *)value;
- (void)addQueues:(NSSet *)values;
- (void)removeQueues:(NSSet *)values;
- (void)addMeetingsObject:(Meeting *)value;
- (void)removeMeetingsObject:(Meeting *)value;
- (void)addMeetings:(NSSet *)values;
- (void)removeMeetings:(NSSet *)values;

@end
