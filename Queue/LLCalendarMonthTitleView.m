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
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
        CGFloat borderWidth = 1.0;
        bottomBorder.frame = CGRectMake(0.0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
        [self.layer addSublayer:bottomBorder];
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
