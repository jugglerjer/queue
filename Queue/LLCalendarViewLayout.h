//
//  LLCalendarViewLayout.h
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/12/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const LLCalendarLayoutWeekdayTitleKind;

@interface LLCalendarViewLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) CGFloat monthHeight;

@end
