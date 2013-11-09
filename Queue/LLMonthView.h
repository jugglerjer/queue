//
//  LLMonthView.h
//  Queue
//
//  Created by Jeremy Lubin on 11/8/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LLMonthViewDelegate;

@interface LLMonthView : UIScrollView

@property (assign, nonatomic) id <LLMonthViewDelegate> delegate;

- (void)loadMonths:(NSArray *)months;
- (void)formatMonthsForScrollVelocity:(CGPoint)velocity;

@end

@protocol LLMonthViewDelegate <NSObject, UIScrollViewDelegate>

- (void)monthView:(LLMonthView *)monthView didSelectPageAtIndex:(NSInteger)index;

@end
