//
//  UIView+NearestViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 8/6/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "UIView+NearestViewController.h"

@implementation UIView (NearestViewController)

- (UIViewController *)nearestViewController
{
    if ([self isKindOfClass:[UIViewController class]])
        return (UIViewController *)self;
    else
        return [[self superview] nearestViewController];
}

@end
