//
//  Meeting.h
//  Queue
//
//  Created by Jeremy Lubin on 6/2/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LLDataDownloader.h"

@class Contact, Location;

typedef enum
{
    MeetingMethodQueue,
    MeetingMethodSnooze,
    MeetingMethodInPerson
} MeetingMethod;

@interface Meeting : NSManagedObject <LLDataDownloaderDelegate>

@property (nonatomic, retain) NSString *salesforceID;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) Location *location;

- (void)populateWithSalesforceEvent:(NSDictionary *)event;
- (void)setLocationWithSearchTerm:(NSString *)searchTerm;

@end
