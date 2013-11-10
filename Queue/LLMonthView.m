//
//  LLMonthView.m
//  Queue
//
//  Created by Jeremy Lubin on 11/8/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLMonthView.h"
#import "LLMonthCell.h"

@interface LLMonthView()
@property (nonatomic, strong) NSMutableArray *monthViews;
@end

@implementation LLMonthView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
        
        _monthViews = [NSMutableArray array];
    }
    return self;
}

- (void)monthSelected:(LLMonthCell *)month
{
    if ([self.delegate respondsToSelector:@selector(monthView:didSelectPageAtIndex:)])
        [self.delegate monthView:self didSelectPageAtIndex:[_monthViews indexOfObject:month]];
}

- (void)loadMonths:(NSArray *)months
{
    // Load all of the months
    for (NSDictionary *monthDict in months) {
        NSDate *month = [[NSCalendar currentCalendar] dateFromComponents:monthDict[@"month"]];
        
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"MMMM"];
        
        NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
        [yearFormatter setDateFormat:@"y"];
        
        NSInteger index = [months indexOfObject:monthDict];
        LLMonthCell *monthView = [[LLMonthCell alloc] initWithFrame:[self frameForMonthCellAtIndex:index]];
        monthView.monthLabel.text = [monthFormatter stringFromDate:month];
        monthView.yearLabel.text = [yearFormatter stringFromDate:month];
        [monthView addTarget:self action:@selector(monthSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_monthViews addObject:monthView];
        [self addSubview:monthView];
    }
}

// ------------------------
// Change the alpha value of
// the months depending upon
// their position on screen
// ------------------------
- (void)formatMonthsForScrollVelocity:(CGPoint)velocity
{
    // Determine which month is the primary visible month
    NSInteger pageWidth = (self.contentSize.width / [_monthViews count]);
    NSInteger page;
    
    if (velocity.x <= 0)
        page = floorf(self.contentOffset.x / pageWidth);
    else
        page = ceilf(self.contentOffset.x / pageWidth);
    
    [self formatMonthAtIndex:page - 2];
    [self formatMonthAtIndex:page - 1];
    [self formatMonthAtIndex:page];
    [self formatMonthAtIndex:page + 1];
    [self formatMonthAtIndex:page + 2];
}

- (void)formatMonthAtIndex:(NSInteger)index
{
    // Return if we're at an index that doesn't exist
    if (index < 0 || index >= [_monthViews count])
        return;
    
    // Calculate the current page's distance from center
    CGRect monthFrame = [self frameForMonthCellAtIndex:index];
    CGFloat center = monthFrame.origin.x;
    CGFloat distance = ABS(self.contentOffset.x - center);
    
    // Assign that distance to a percentage that will indicate opacity
    CGFloat percentage = 1.0 - (distance / monthFrame.size.width);
    CGFloat alpha = percentage < 0.2 ? 0.2 : percentage;
    
    LLMonthCell *cell = [_monthViews objectAtIndex:index];
    cell.monthLabel.alpha = alpha;
}

- (CGRect)frameForMonthCellAtIndex:(NSInteger)index
{
    // The month view should sit at the top of the collection view
    // and be positioned to the right of all previous month title's
    CGFloat originX = self.frame.size.width * index;
    return CGRectMake(originX, 0.0, self.bounds.size.width, self.bounds.size.height);
}

// Ensure that iOS7 doesn't break our contentInset
- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
}

// --------------------------------------------------------
// Overriding this method to allow touches to pass through
// the month view and directly to the underlying day view.
// If we don't do this, only the current month of the month
// view is scrollable because the other months are outside
// of the view's frame.
// --------------------------------------------------------
//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//    NSLog(@"%@", );
//    return YES;
//}


@end
