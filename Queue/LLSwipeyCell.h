//
//  LLSwipeyCell.h
//  Queue
//
//  Created by Jeremy Lubin on 7/27/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LLSwipeyCellDelegate;

@interface LLSwipeyCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <LLSwipeyCellDelegate> delegate;
@property CGFloat dragThreshold;

@end

@protocol LLSwipeyCellDelegate <NSObject>

- (void)swipeyCellDidBeginDragging:(LLSwipeyCell *)cell;
- (void)swipeyCellDidDrag:(LLSwipeyCell *)cell;
- (void)swipeyCellDidEndDragging:(LLSwipeyCell *)cell;
- (void)swipeyCellDidDismiss:(LLSwipeyCell *)cell;
- (void)swipeyCellDidReset:(LLSwipeyCell *)cell;

@end
