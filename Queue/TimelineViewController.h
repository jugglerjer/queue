//
//  TimelineViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/20/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMeetingViewController.h"
#import "AddContactViewController.h"
#import "LLDataDownloader.h"
#import "MeetingCell.h"
@class Contact;
@class Meeting;
@class QueueViewController;

@protocol TimelineViewControllerDelegate;

@interface TimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddMeetingViewControllerDelegate, AddContactViewControllerDelegate, LLDataDownloaderDelegate, MeetingCellDelegate>

@property (weak, nonatomic) id<TimelineViewControllerDelegate> delegate;
@property (strong, nonatomic) Contact * contact;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) QueueViewController *queueViewController;

- (id)initWithContact:(Contact *)contact;
- (void)showToolbelt;
- (void)hideToolbelt;

@end

@protocol TimelineViewControllerDelegate <NSObject>

- (void)timelineViewController:(TimelineViewController *)timelineViewController
              didUpdateContact:(Contact *)contact
                   withMeeting:(Meeting *)meeting;

- (void)timelineViewController:(TimelineViewController *)timelineViewController shouldDeleteContact:(Contact *)contact;

@end
