//
//  QueueCell.h
//  Queue
//
//  Created by Jeremy Lubin on 6/13/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSwipeyCell.h"

@protocol QueueCellDelegate;

@interface QueueCell : LLSwipeyCell <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <QueueCellDelegate> delegate;
@property (strong, nonatomic) UITextField *queueNameLabel;
@property (strong, nonatomic) UILabel *deleteLabel;
@property (strong, nonatomic) UIImageView *unselectedImageView;
@property (strong, nonatomic) UIImageView *selectedImageView;
@property (strong, nonatomic) UIImageView *selectableBackgroundView;
@property (weak, nonatomic) UITableView *queueTable;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setSelectable:(BOOL)selectable animated:(BOOL)animated;
- (void)setActive:(BOOL)active animated:(BOOL)animated;

@end

@protocol QueueCellDelegate <NSObject, LLSwipeyCellDelegate>

- (void)queueCell:(QueueCell *)cell didEndNameEditingWithNewName:(NSString *)name;
- (void)queueCellDidDeleteQueue:(QueueCell *)cell;

@end
