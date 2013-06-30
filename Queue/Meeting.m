//
//  Meeting.m
//  Queue
//
//  Created by Jeremy Lubin on 6/2/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "Meeting.h"
#import "Contact.h"
#import "Location.h"


@implementation Meeting

@dynamic date;
@dynamic method;
@dynamic note;
@dynamic contact;
@dynamic location;

// ------------------------
// Convert the meeting method
// into a string and save it
// to the object
// ------------------------
//- (void)setMeetingMethod:(MeetingMethod)method
//{
//    switch (method) {
//        case MeetingMethodQueue:
//            self.method = @"queue";
//            break;
//        case MeetingMethodSnooze:
//            self.method = @"snooze"
//            
//        default:
//            break;
//    }
//}

@end
