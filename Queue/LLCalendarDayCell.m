//
//  LLCalendarDayCell.m
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/9/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLCalendarDayCell.h"

@interface LLCalendarDayCell ()

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDateComponents *monthComponent;

@property (strong, nonatomic) UIColor *selectedTextColor;
@property (strong, nonatomic) UIColor *currentMonthTextColor;
@property (strong, nonatomic) UIColor *otherMonthTextColor;

@end

@implementation LLCalendarDayCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _selectedTextColor = [UIColor whiteColor];
        _currentMonthTextColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
        _otherMonthTextColor = [UIColor lightGrayColor];
        
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setDateFormat:@"d"];
        
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.textColor = _currentMonthTextColor;
        _dateLabel.font = [UIFont systemFontOfSize:15.0];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_dateLabel];
    }
    return self;
}

- (void)configureWithDate:(NSDate *)date andMonthComponent:(NSDateComponents *)monthComponent
{
    _date = date;
    _monthComponent = monthComponent;
    
    UIColor *textColor = [self dateTextColor];
    
    _dateLabel.textColor = textColor;
    _dateLabel.text = [_dateFormat stringFromDate:date];
    _dateLabel.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _dateLabel.backgroundColor = [self dateBackgroundColor];
    _dateLabel.textColor = [self dateTextColor];
}

- (UIColor *)dateTextColor
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:_date];
    [dateComponents setDay:1];
    UIColor *textColor = [[UIColor alloc] init];
    
    if (self.selected)
    {
        return _selectedTextColor;
    }
    
    if ([dateComponents isEqual:_monthComponent])
    {
        textColor = _currentMonthTextColor;
    }
    
    else
    {
        textColor = _otherMonthTextColor;
    }
    
    return textColor;
}

- (UIColor *)dateBackgroundColor
{
    UIColor *newBackgroundColor;
    
    if (self.selected)
    {
        newBackgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
    }
    
    else
    {
        newBackgroundColor = [UIColor clearColor];
    }
    
    return newBackgroundColor;
}



@end
