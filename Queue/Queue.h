//
//  Queue.h
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Queue : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *contacts;

- (BOOL)containsContact:(Contact *)contact;
- (NSArray *)sortedContacts;

@end

@interface Queue (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
