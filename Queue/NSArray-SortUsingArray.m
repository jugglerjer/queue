//
//  NSArray-SortUsingArray.m
//  inTouch
//
//  Created by Jeremy Lubin on 8/7/09.
//  Copyright 2009 New York University. All rights reserved.
//

#import "NSArray-SortUsingArray.h"


@implementation NSArray(SortUsingArray)

static NSInteger comparatorForSortingUsingArray(id object1, id object2, void *context)
{
	NSUInteger index1 = [(__bridge NSArray *)context indexOfObject:object1];
	NSUInteger index2 = [(__bridge NSArray *)context indexOfObject:object2];
	if (index1 <index2)
		return NSOrderedAscending;
	if (index1 > index2)
		return NSOrderedDescending;
	return [object1 compare:object2];
}

- (NSArray *)sortedArrayUsingArray:(NSArray *)otherArray
{
	return [self sortedArrayUsingFunction:comparatorForSortingUsingArray context:(__bridge void *)(otherArray)];
}

@end
