//
//  LLPullNavigationTableView.m
//  Queue
//
//  Created by Jeremy Lubin on 6/9/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLPullNavigationTableView.h"
#import "LLPullNavigationScrollView.h"

@implementation LLPullNavigationTableView

BOOL isScrollingUp = NO;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
//        for (id gestureRecognizer in [self gestureRecognizers])
//        {
//            if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
//            {
//                [gestureRecognizer addTarget:self action:@selector(handleSwipe:)];
//            }
//        }
    }
    return self;
}
//
//- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
//{
//    
//}

//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//    return YES;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [[touches allObjects] objectAtIndex:0];
//    CGPoint currentLocation = [touch locationInView:self];
//    CGPoint previousLocation = [touch previousLocationInView:self];
//    
//    // Loop through all superviews to find the LLPullNavigationSwipeView
//    id view = self;
//    LLPullNavigationScrollView *scrollView;
//    while (view != nil)
//    {
//        view = [view superview];
//        if ([view isKindOfClass:[LLPullNavigationScrollView class]])
//        {
//            scrollView = (LLPullNavigationScrollView *)view;
//            [scrollView touchesMoved:touches withEvent:event];
//            [super touchesCancelled:touches withEvent:event];
//            break;
//        }
//    }
//    
//    if (previousLocation.y < currentLocation.y && self.contentOffset.y <= 0)
//    {
//        NSLog(@"Scrolled up on table");
//        scrollView.scrollEnabled = YES;
//        isScrollingUp = YES;
//    }
//    else
//    {
//        NSLog(@"Scrolled down on table");
//        scrollView.scrollEnabled = NO;
//        [self becomeFirstResponder];
//        isScrollingUp = NO;
//        [super touchesMoved:touches withEvent:event];
//    }
//    
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (isScrollingUp)
//        return NO;
//    return YES;
//}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UITouch *myTouch = [[event allTouches] anyObject];
//    if (self.contentOffset.y <= 0) {
//        return NO;
//    }
//    return YES;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
