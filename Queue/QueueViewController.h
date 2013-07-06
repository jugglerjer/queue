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
#import "AddContactViewController.h"
#import "TimelineViewController.h"
#import "QueueContactCell.h"
@class Queue;
@class LLPullNavigationTableView;

@interface QueueViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, TimelineViewControllerDelegate, UIGestureRecognizerDelegate, QueueContactCellDelegate, AddContactViewControllerDelegate>

@property (strong, nonatomic) Queue *queue;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) LLPullNavigationTableView *tableView;
@property (strong, nonatomic) NSIndexPath * selectedIndexPath;

- (id)initWithQueue:(Queue *)queue;

@end
