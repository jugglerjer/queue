//
//  QueueContactCell.h
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;

@protocol QueueContactCellDelegate;

@interface QueueContactCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic)   id <QueueContactCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *backgroundWell;
@property (strong, nonatomic) UIImageView *contactImage;
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

- (void)queueContactCellDidDismiss:(QueueContactCell *)cell;
- (void)queueContactCellDidBeginDragging:(QueueContactCell *)cell;
- (void)queueContactCellDidEndDragging:(QueueContactCell *)cell;

@end
