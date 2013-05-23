//
//  Meeting.h
//  Queue
//
//  Created by Jeremy Lubin on 5/19/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Meeting : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Contact *contact;

@end
