//
//  LLCalendarWeekdayView.m
//  Queue
//
//  Created by Jeremy Lubin on 11/8/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLCalendarWeekdayView.h"

@implementation LLCalendarWeekdayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Set up weekday labels
        NSArray *weekdayTitles = @[@"SUN", @"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT"];
        CGFloat weekdayLabelWidth = self.frame.size.width / [weekdayTitles count];
        CGFloat weekdayLabelHeight = 30.0;
        for (NSString *weekdayTitle in weekdayTitles)
        {
            NSInteger index = [weekdayTitles indexOfObject:weekdayTitle];
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(weekdayLabelWidth * index,
                                                                              self.frame.size.height - weekdayLabelHeight,
                                                                              weekdayLabelWidth,
                                                                              weekdayLabelHeight)];
//            weekdayLabel.textColor = [UIColor grayColor];
            weekdayLabel.font = [UIFont systemFontOfSize:11.0];
            weekdayLabel.text = weekdayTitle;
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:weekdayLabel];
        }
        
    }
    return self;
}

@end
