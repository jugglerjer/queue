//
//  TimelineViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/20/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMeetingViewController.h"
@class Contact;

@interface TimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddMeetingViewControllerDelegate>

@property (strong, nonatomic) Contact * contact;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithContact:(Contact *)contact;

@end
