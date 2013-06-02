//
//  AddMeetingViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/19/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Meeting;
@class Contact;

@protocol AddMeetingViewControllerDelegate;

typedef enum
{
    QueueEditMeetingTypeAdd,
    QueueEditMeetingTypeUpdate
} QueueEditMeetingType;

@interface AddMeetingViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) id<AddMeetingViewControllerDelegate> delegate;
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property QueueEditMeetingType editMeetingType;

- (id)initWithMeeting:(Meeting *)meeting;

@end

@protocol AddMeetingViewControllerDelegate <NSObject>
- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController
                   didAddMeeting:(Meeting *)meeting
                      forContact:(Contact *)contact;

- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController
                didUpdateMeeting:(Meeting *)meeting
                      forContact:(Contact *)contact;

@end
