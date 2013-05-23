//
//  QueueViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/16/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AddMeetingViewController.h"
@class Queue;

@interface QueueViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Queue *queue;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithQueue:(Queue *)queue;

@end
