//
//  LLSwipeyCell.h
//  Queue
//
//  Created by Jeremy Lubin on 7/27/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    LLSwipeyCellDetailTypeUnderneath,
    LLSwipeyCellDetailTypeAdjacent
} LLSwipeyCellDetailType;

@protocol LLSwipeyCellDelegate;

@interface LLSwipeyCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <LLSwipeyCellDelegate> delegate;
@property LLSwipeyCellDetailType detailType;
@property (strong, nonatomic) UIView *swipeyView;
@property (strong, nonatomic) UIView *underView;
@property BOOL isDragging;
@property CGFloat dragThreshold;

@property BOOL swipingEnabled;

- (id)initWithDetailType:(LLSwipeyCellDetailType)detailType reuseIdentifier:(NSString *)reuseIdentifier;
- (void)resetCellWithAnimation:(BOOL)animated;
- (void)dismissCellWithAnimation:(BOOL)animated velocity:(CGPoint)velocity;


@end

@protocol LLSwipeyCellDelegate <NSObject>

- (void)swipeyCellDidBeginDragging:(LLSwipeyCell *)cell;
- (void)swipeyCellDidDrag:(LLSwipeyCell *)cell;
- (void)swipeyCellDidEndDragging:(LLSwipeyCell *)cell;
- (void)swipeyCellDidDismiss:(LLSwipeyCell *)cell;
- (void)swipeyCellDidReset:(LLSwipeyCell *)cell;

@end
