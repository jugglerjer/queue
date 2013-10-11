//
//  LLCalendarViewController.m
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/9/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLDatePicker.h"
#import "LLCalendarView.h"
#import "LLCalendarViewLayout.h"
#import "LLCalendarDayCell.h"
#import "LLCalendarMonthTitleView.h"
#import "NSDate+Helper.h"

static NSString * const CalendarDayCellIdentifier = @"CalendarDayCell";
static NSString * const MonthTitleViewIdentifier = @"MonthTitleView";

@interface LLDatePicker ()

@property NSArray *datesArray;
@property NSArray *monthsArray;
@property UICollectionView *calendarView;

@end

@implementation LLDatePicker

#define KeyboardHeight           216
#define ToolbarHeight            44
#define kNumberOfDaysInWeek      7
#define kNumberOfWeeksInMonth    6
#define kNumberOfMonthsToDisplay 25
#define secondsInDay() (60 * 60 * 24)
#define kCalendarAnimationDuration  0.5f

- (id)init
{
    if (self = [super init])
    {
        // Initiate date management
        [self setupCalendarView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Initiate date management
        [self setupCalendarView];
    }
    return self;
}

# pragma mark - Calendar Configuration Methods

- (void)setupCalendarView
{
    [self setupDates];
    
    // Create the calendar layout object
    LLCalendarViewLayout *calendarLayout = [[LLCalendarViewLayout alloc] init];
    
    // Create the calendar collection view
    CGRect calendarFrame = [self shownCalendarFrame];
    _calendarView = [[LLCalendarView alloc] initWithFrame:calendarFrame collectionViewLayout:calendarLayout];
    _calendarView.dataSource = self;
    _calendarView.delegate = self;
    [_calendarView registerClass:[LLCalendarDayCell class] forCellWithReuseIdentifier:CalendarDayCellIdentifier];
    [_calendarView registerClass:[LLCalendarMonthTitleView class] forSupplementaryViewOfKind:LLCalendarLayoutMonthTitleKind withReuseIdentifier:MonthTitleViewIdentifier];
    [self addSubview:_calendarView];
    
    // Scroll to the current month
    [self setDate:[NSDate date] animated:NO];
}

- (void)setDate:(NSDate *)date
{
    [self setDate:date animated:NO];
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
    _date = date;
    
    NSIndexPath *indexPath = [self indexPathForDate:date];
    if (indexPath) {
        [_calendarView selectItemAtIndexPath:indexPath animated:animated scrollPosition:UICollectionViewScrollPositionNone];
        [self scrollToSection:indexPath.section animated:animated];
    }
}

- (CGRect)shownCalendarFrame
{
    return CGRectMake(0.0,
                      0.0,
                      self.frame.size.width,
                      KeyboardHeight + ToolbarHeight);
}

- (CGRect)hiddenCalendarFrame
{
    return CGRectMake(0.0,
                      self.frame.size.height,
                      self.frame.size.width,
                      KeyboardHeight + ToolbarHeight);
}

# pragma mark - Calendar Data Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kNumberOfMonthsToDisplay;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kNumberOfDaysInWeek * kNumberOfWeeksInMonth;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LLCalendarDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CalendarDayCellIdentifier forIndexPath:indexPath];
    
    NSDate *date = _datesArray[indexPath.section][@"days"][indexPath.item];
    NSDateComponents *month = _datesArray[indexPath.section][@"month"];
    [cell configureWithDate:date andMonthComponent:month];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LLCalendarMonthTitleView *monthView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MonthTitleViewIdentifier forIndexPath:indexPath];
    NSDate *month = [[NSCalendar currentCalendar] dateFromComponents:_datesArray[indexPath.section][@"month"]];
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MMMM, y"];
    monthView.monthLabel.text = [monthFormatter stringFromDate:month];
    return monthView;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    NSInteger section = [self sectionForDate:date];
    NSInteger item = [self itemInSection:section forDate:date];
    
    // Make sure we have a real section and item
    if (section == NSNotFound || item == NSNotFound) return nil;
    
    // Return the indexPath if the date exists, otherwise return the indexPath for today
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    // Find the date's month and year and create a date components object
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    [dateComponents setDay:1];
    
    // Find the index of the date component in an array of the month keys to find the section
    NSMutableArray *months = [NSMutableArray arrayWithCapacity:[_datesArray count]];
    for (NSDictionary *month in _datesArray) {
        [months addObject:month[@"month"]];
    }
    return [months indexOfObject:dateComponents];
}

- (NSInteger)itemInSection:(NSInteger)section forDate:(NSDate *)date
{
    // Make sure that the section exists
    if (section == NSNotFound) return NSNotFound;
    
    // Recreate the date, with just day, month and year attributes, to find the item
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                                   fromDate:date];
    NSArray *days = _datesArray[section][@"days"];
    NSMutableArray *daysComponents = [NSMutableArray arrayWithCapacity:[days count]];
    for (NSDate *day in days) {
        NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                                      fromDate:day];
        [daysComponents addObject:dayComponents];
    }
    return [daysComponents indexOfObject:dateComponents];
}

# pragma mark - Date Handling Methods

- (void)setupDates
{
    // Determine the start date for the calendar view
    // by taking a predefined number of months on either side
    // of the given midpoint date
    NSInteger previousMonthCount = (kNumberOfMonthsToDisplay - 1) / 2;
    
    NSDate *midPointDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *midPointDateComponents = [calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:midPointDate];
    CGFloat previousYearCount = floor(previousMonthCount / 12);
    NSInteger remainderMonthCount = previousMonthCount % 12;
    midPointDateComponents.year -= previousYearCount;
    midPointDateComponents.month -= remainderMonthCount;
    NSDate *startDate = [calendar dateFromComponents:midPointDateComponents];
    
    // Create an array of months wherein each
    // item is populated with an array of dates
    // ----------------------------------------
    NSMutableArray *months = [NSMutableArray arrayWithCapacity:kNumberOfMonthsToDisplay];
    NSDateComponents *monthComponent = [[NSDateComponents alloc] init];
    [monthComponent setMonth:1];
    NSDate *nextMonthDate = startDate;
    for (NSInteger i = 0; i < kNumberOfMonthsToDisplay; i++)
    {
        NSDateComponents *monthAndYearComponents = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:nextMonthDate];
        NSArray *days = [self datesForMonthAndYearComponents:monthAndYearComponents];
        NSDictionary *month = @{@"month": monthAndYearComponents, @"days": days};
        [months addObject:month];
        nextMonthDate = [calendar dateByAddingComponents:monthComponent toDate:nextMonthDate options:0];
    }
    
    _datesArray = months;
}

- (NSArray *)datesForMonthAndYearComponents:(NSDateComponents *)components
{
    NSMutableArray *dates = [NSMutableArray arrayWithCapacity:kNumberOfDaysInWeek * kNumberOfWeeksInMonth];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Determine how many dates that need to be displayed prior to and after the given month
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *weekdayComponent = [calendar components:NSWeekdayCalendarUnit fromDate:firstDate];
    NSInteger numberOfDaysBefore = [weekdayComponent weekday] - 1;
    NSInteger numberOfDaysAfter = (kNumberOfDaysInWeek * kNumberOfWeeksInMonth) - (numberOfDaysBefore + [firstDate daysInMonth]);
    
    // Fetch each of the dates that need to be displayed prior to the first day of the given month
    for (NSInteger i = numberOfDaysBefore; i > 0; i--)
    {
        NSDate *priorDate = [NSDate dateWithTimeInterval:-(i*secondsInDay()) sinceDate:firstDate];
        [dates addObject:priorDate];
    }
    
    // Create each of the dates in the month
    for (NSInteger i = 0; i < [firstDate daysInMonth] ; i++)
    {
        NSDate *nextDate = [NSDate dateWithTimeInterval:i*secondsInDay() sinceDate:firstDate];
        [dates addObject:nextDate];
    }
    
    // Create of the dates that fall after the current month ends
    NSDate *lastDateOfMonth = [dates lastObject];
    for (NSInteger i = 1; i <= numberOfDaysAfter; i++)
    {
        NSDate *postDate = [NSDate dateWithTimeInterval:i*secondsInDay() sinceDate:lastDateOfMonth];
        [dates addObject:postDate];
    }
    
    return dates;
}

# pragma mark - Calendar Delegate Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _date = _datesArray[indexPath.section][@"days"][indexPath.item];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

# pragma mark - Calendar Animation Methods

- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated
{
   [_calendarView setContentOffset:CGPointMake(section * self.bounds.size.width, 0.0) animated:animated];
}

- (void)hideWithAnimation:(BOOL)animated
{
    [self hideWithAnimation:animated afterDelay:0.0f completion:nil];
}

- (void)hideWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    [self hideWithAnimation:animated afterDelay:delay completion:nil];
}

- (void)hideWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(void (^)())completionBlock
{
    CGRect frame = [self hiddenCalendarFrame];
    NSTimeInterval duration = animated ? kCalendarAnimationDuration : 0.0f;
    [self setFrame:frame withDuration:duration afterDelay:delay completion:completionBlock];
    self.userInteractionEnabled = NO;
}

- (void)showWithAnimation:(BOOL)animated
{
    [self showWithAnimation:animated afterDelay:0.0f completion:nil];
}

- (void)showWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    [self showWithAnimation:animated afterDelay:delay completion:nil];
}

- (void)showWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(void (^)())completionBlock
{
    CGRect frame = [self shownCalendarFrame];
    NSTimeInterval duration = animated ? kCalendarAnimationDuration : 0.0f;
    [self setFrame:frame withDuration:duration afterDelay:delay completion:completionBlock];
    self.userInteractionEnabled = YES;
    
}

- (void)setFrame:(CGRect)frame withDuration:(NSTimeInterval)duration afterDelay:(NSTimeInterval)delay completion:(void (^)())completionBlock
{
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                     animations:^{_calendarView.frame = frame;}
                     completion:^(BOOL finished){
                         if (completionBlock != nil)
                             completionBlock();
                     }];
}

@end
