//
//  LLCalendarMonthTitleView.m
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/28/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLCalendarMonthTitleView.h"

@interface LLCalendarMonthTitleView ()
@property (strong, nonatomic, readwrite) UILabel *monthLabel;
@end

@implementation LLCalendarMonthTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _monthLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _monthLabel.backgroundColor = [UIColor clearColor];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_monthLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _monthLabel.text = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
