//
//  LLCalendarDayCell.h
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/9/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCalendarDayCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) NSDateFormatter *dateFormat;

- (void)configureWithDate:(NSDate *)date andMonthComponent:(NSDateComponents *)monthComponent;

@end

@interface LLCalendarDayCellSelectionCircle : UIView

@end
