//
//  Queue.m
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "Queue.h"
#import "Contact.h"


@implementation Queue

@dynamic name;
@dynamic contacts;

// -------------------------------------------------------------
// Check whether the queue already contains a contact
// -------------------------------------------------------------
- (BOOL)containsContact:(Contact *)contact
{
    // Create an array of all the addressBookIDs
    for (Contact *existingContact in self.contacts) {
        if ([existingContact.addressBookID isEqualToNumber:contact.addressBookID])
        {
            return YES;
        }
    }
    return NO;
}

// -------------------------------------------------------------
// Return an array of the queue's contact sorted by due date
// -------------------------------------------------------------
- (NSArray *)sortedContacts
{    
    return [[self.contacts allObjects] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Contact*)a dueDateIncludingSnoozes:YES];
        NSDate *second = [(Contact*)b dueDateIncludingSnoozes:YES];
        return [first compare:second];
    }];
}

// -------------------------------------------------------------
// Give the Queue a unique name. If there's another Queue by the
// same name, add a trailing number to differentiate this Queue.
// For example, if this Queue's name is "Queue" and another "Queue"
// exists, change the name of this Queue to "My Queue 1"
// -------------------------------------------------------------
//- (void)setUniqueName:(NSString *)name givenOtherQueues:(NSArray *)queues
//{
//    int trailer = 0;
//    NSString *tempName = [name copy];
//    for (Queue *queue  in queues) {
//        if ([tempName isEqualToString:queue.name]) {
//            tempName = [tempName stringByAppendingFormat:@"%i", trailer++];
//        }
//    }
//}

@end
