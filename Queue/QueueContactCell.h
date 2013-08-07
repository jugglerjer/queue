//
//  QueueContactCell.h
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueueContactImageView.h"
#import "LLSwipeyCell.h"
#import "AddMeetingViewController.h"
@class Contact;
@class Meeting;
@class Location;

@protocol QueueContactCellDelegate;

typedef enum
{
    QueueContactCellDismissalTypeQueue,
    QueueContactCellDismissalTypeSnooze,
    QueueContactCellDismissalTypeMeeting
} QueueContactCellDismissalType;

@interface QueueContactCell : LLSwipeyCell <UIGestureRecognizerDelegate, QueueContactImageViewDelegate, AddMeetingViewControllerDelegate>

@property (nonatomic, assign) id <QueueContactCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *backgroundWell;
@property (strong, nonatomic) QueueContactImageView *contactImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dueDateLabel;
@property (strong, nonatomic) UILabel *unitsLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *dueLabel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithContact:(Contact *)contact andImage:(UIImage *)image;
- (void)configureWithMeeting:(Meeting *)meeting;
- (UIImage *)avatarImageForContact:(Contact *)contact;
//- (void)resetCellPositionWithAnimation:(BOOL)animated;

@end

@protocol QueueContactCellDelegate <NSObject, LLSwipeyCellDelegate>

- (void)queueContactCell:(QueueContactCell *)cell didSetImage:(UIImage *)image forContact:(Contact *)contact;
- (void)queueContactCell:(QueueContactCell *)cell didDismissWithType:(QueueContactCellDismissalType)type;
- (void)queueContactCell:(QueueContactCell *)cell didDismissWithType:(QueueContactCellDismissalType)type andMeeting:(Meeting *)meeting;
- (void)queueContactCell:(QueueContactCell *)cell didRequestMeetingEditWithMeeting:(Meeting *)meeting;
//- (void)queueContactCellDidBeginDragging:(QueueContactCell *)cell;
//- (void)queueContactCellDidEndDragging:(QueueContactCell *)cell;

@end
