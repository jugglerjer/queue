//
//  QueueContactCell.h
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueueContactImageView.h"
@class Contact;

@protocol QueueContactCellDelegate;

typedef enum
{
    QueueContactCellDismissalTypeQueue,
    QueueContactCellDismissalTypeSnooze
} QueueContactCellDismissalType;

@interface QueueContactCell : UITableViewCell <UIGestureRecognizerDelegate, QueueContactImageViewDelegate>

@property (weak, nonatomic)   id <QueueContactCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *backgroundWell;
@property (strong, nonatomic) QueueContactImageView *contactImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dueDateLabel;
@property (strong, nonatomic) UILabel *unitsLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *dueLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithContact:(Contact *)contact;
- (void)resetCellPositionWithAnimation:(BOOL)animated;

@end

@protocol QueueContactCellDelegate <NSObject>

- (void)queueContactCell:(QueueContactCell *)cell didDismissWithType:(QueueContactCellDismissalType)type;
- (void)queueContactCellDidBeginDragging:(QueueContactCell *)cell;
- (void)queueContactCellDidEndDragging:(QueueContactCell *)cell;

@end
