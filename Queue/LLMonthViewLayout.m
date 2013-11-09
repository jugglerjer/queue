//
//  LLMonthViewLayout.m
//  Queue
//
//  Created by Jeremy Lubin on 11/8/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLMonthViewLayout.h"

#define kScreenWidth             320

static NSString * const LLMonthLayoutMonthCellKind = @"MonthCell";

@interface LLMonthViewLayout()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@end

@implementation LLMonthViewLayout

- (id)init
{
    if (self = [super init])
    {
        _monthWidth = kScreenWidth * 1.0;
    }
    return self;
}

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++)
    {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++)
        {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForMonthCellAtIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[LLMonthLayoutMonthCellKind] = cellLayoutInfo;
    _layoutInfo = newLayoutInfo;
}

- (CGRect)frameForMonthCellAtIndexPath:(NSIndexPath *)indexPath
{
    // The month view should sit at the top of the collection view
    // and be positioned to the right of all previous month title's
    CGFloat originX = _monthWidth * indexPath.section;
    return CGRectMake(originX, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
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
    return _layoutInfo[LLMonthLayoutMonthCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    // Return a size struct with the content view's height and the width of all of it's sections
    NSInteger width = [self.collectionView numberOfSections] * self.collectionView.frame.size.width;
    return CGSizeMake(width, self.collectionView.bounds.size.height);
}

@end
