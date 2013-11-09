//
//  LLCalendarViewLayout.m
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/12/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLCalendarViewLayout.h"

#define kScreenWidth             320
#define kKeyboardHeight          172
#define kToolbarHeight           44
#define kNumberOfDaysInWeek      7
#define kNumberOfWeeksInMonth    6

static NSString * const LLCalendarLayoutDayCellKind = @"DayCell";
NSString * const LLCalendarLayoutMonthTitleKind = @"MonthTitle";
NSString * const LLCalendarLayoutWeekdayTitleKind = @"WeekdayTitle";

@interface LLCalendarViewLayout()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@end

@implementation LLCalendarViewLayout

- (id)init
{
    if (self = [super init])
    {
        _itemInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        _monthHeight = kToolbarHeight;
        _itemSize = CGSizeMake(kScreenWidth / kNumberOfDaysInWeek, kKeyboardHeight / kNumberOfWeeksInMonth);
        _interItemSpacingY = 0.0;
        _numberOfColumns = kNumberOfDaysInWeek;
        _numberOfRows = kNumberOfWeeksInMonth;
    }
    return self;
}

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++)
    {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:LLCalendarLayoutWeekdayTitleKind withIndexPath:indexPath];
        titleAttributes.frame = [self frameForMonthTitleAtIndexPath:indexPath];
        titleLayoutInfo[indexPath] = titleAttributes;
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        
        
        for (NSInteger item = 0; item < itemCount; item++)
        {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForCalendarDayCellAtIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[LLCalendarLayoutDayCellKind] = cellLayoutInfo;
    newLayoutInfo[LLCalendarLayoutWeekdayTitleKind] = titleLayoutInfo;
    _layoutInfo = newLayoutInfo;
}

- (CGRect)frameForCalendarDayCellAtIndexPath:(NSIndexPath *)indexPath
{
    // Calculate the cell's origin-x
    // by adding the cumulative width of all previous sections
    // to the cumulative width of all previous cells in this section
    // that fall within the same row
    NSInteger column = indexPath.item < _numberOfColumns ? indexPath.item : indexPath.item % _numberOfColumns;
    CGFloat originX = _itemSize.width * (indexPath.section * _numberOfColumns + column);
    
    // Calculate the cell's origin-y
    // by adding the cumulative width of the previous cells in this section
    // that fall within the same column
    NSInteger row = indexPath.item / _numberOfColumns;
    CGFloat originY = _itemSize.height * row + _monthHeight;
    
    // Because the iPhone's screen width of 320 units is not divisible by 7,
    // it's impossible to evenly space the days of the week on the calendar.
    // Instead, we'll add a tiny number of additional pixels to the items in
    // certain columns in order to space the grid properly.
    // If the cell is in the first or last column, add 2 pixels to its width
    // If it's in the middle column, add 1 pixel
    CGFloat width = _itemSize.width;
    CGFloat sectionOriginXOffset = indexPath.section * 5.0;
    switch (column) {
        case 0:
            width += 2.0;
            break;
        case 1:
            width += 0.0;
            originX += 2.0;
            break;
        case 2:
            width += 0.0;
            originX += 2.0;
            break;
        case 3:
            width += 1.0;
            originX += 2.0;
            break;
        case 4:
            width += 0.0;
            originX += 3.0;
            break;
        case 5:
            width += 0.0;
            originX += 3.0;
            break;
        case 6:
            width += 2.0;
            originX += 3.0;
            break;
        default:
            break;
    }
    
    return CGRectMake(originX + sectionOriginXOffset, originY, width, _itemSize.height);
}

- (CGRect)frameForMonthTitleAtIndexPath:(NSIndexPath *)indexPath
{
    // The title view should sit at the top of the collection view
    // and be positioned to the right of all previous month title's
    CGFloat originX = self.collectionView.bounds.size.width * indexPath.section;
    return CGRectMake(originX, 0.0, self.collectionView.bounds.size.width, _monthHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _layoutInfo[LLCalendarLayoutDayCellKind][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return _layoutInfo[LLCalendarLayoutWeekdayTitleKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    // Return a size struct with the content view's height and the width of all of it's sections
    NSInteger width = [self.collectionView numberOfSections] * (_numberOfColumns * _itemSize.width + 5.0);
    return CGSizeMake(width, self.collectionView.bounds.size.height);
}

@end
