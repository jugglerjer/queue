//
//  LLMonthCell.m
//  Queue
//
//  Created by Jeremy Lubin on 11/8/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLMonthCell.h"

@implementation LLMonthCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect monthFrame = self.bounds;
        monthFrame.size.height /= 2.0;
        monthFrame.origin.y += 4.0;
        _monthLabel = [[UILabel alloc] initWithFrame:monthFrame];
        _monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _monthLabel.backgroundColor = [UIColor clearColor];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        _monthLabel.font = [UIFont systemFontOfSize:19.0];
        [self addSubview:_monthLabel];
        
        CGRect yearFrame = self.bounds;
        yearFrame.size.height /= 2.0;
        yearFrame.origin.y += self.bounds.size.height / 2.0;
        _yearLabel = [[UILabel alloc] initWithFrame:yearFrame];
        _yearLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _yearLabel.backgroundColor = [UIColor clearColor];
        _yearLabel.textAlignment = NSTextAlignmentCenter;
        _yearLabel.font = [UIFont systemFontOfSize:11.0];
        _yearLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_yearLabel];
        
    }
    return self;
}

@end
