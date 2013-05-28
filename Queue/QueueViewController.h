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
#import "TimelineViewController.h"
@class Queue;

@interface QueueViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, TimelineViewControllerDelegate>

@property (strong, nonatomic) Queue *queue;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath * selectedIndexPath;

- (id)initWithQueue:(Queue *)queue;

@end
