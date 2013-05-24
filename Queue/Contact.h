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


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * addressBookID;
@property (nonatomic, retain) NSNumber * meetInterval;
@property (nonatomic, retain) NSDate   * dateAdded;
@property (nonatomic, retain) NSSet *queues;
@property (nonatomic, retain) NSSet *meetings;

- (void)populateWithAddressBookRecord:(ABRecordRef)person;
- (NSDate *)dueDate;
- (double)weeksUntilDue;
- (NSArray *)sortedMeetings;

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
