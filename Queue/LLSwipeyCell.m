//
//  LLSwipeyCell.m
//  Queue
//
//  Created by Jeremy Lubin on 7/27/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLSwipeyCell.h"

@implementation LLSwipeyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _underView = [[UIView alloc] initWithFrame:self.bounds];
        _swipeyView = [[UIView alloc] initWithFrame:self.bounds];
        
        [self addSubview:_underView];
        [self addSubview:_swipeyView];
        
        // Add pan gesture recognizer for swiping
        UIPanGestureRecognizer *queueGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        queueGesture.delegate = self;
        [_swipeyView addGestureRecognizer:queueGesture];
    }
    return self;
}

// -----------------------------
// Handle dragging the cell left
// in order to queue the contact
// -----------------------------
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint distance = [gestureRecognizer translationInView:_swipeyView.superview];
    CGRect frame;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([_delegate respondsToSelector:@selector(swipeyCellDidBeginDragging:)])
                [_delegate swipeyCellDidBeginDragging:self];
            break;
            
        case UIGestureRecognizerStateChanged:
            NSLog(@"%f, %f", _dragThreshold, distance.x);
            frame = _swipeyView.frame;
            
            if (distance.x < 0)
            {
                frame.origin.x = distance.x;
                [_swipeyView setFrame:frame];
            }
            
            if ([_delegate respondsToSelector:@selector(swipeyCellDidDrag:)])
                [_delegate swipeyCellDidDrag:self];
            
            break;
            
        case UIGestureRecognizerStateEnded:
            if (ABS(distance.x) > _dragThreshold)
                [self dismissCellWithAnimation:YES velocity:[gestureRecognizer velocityInView:_swipeyView.superview]];
            else
                [self resetCellWithAnimation:YES];
            
            if ([_delegate respondsToSelector:@selector(swipeyCellDidEndDragging:)])
                [_delegate swipeyCellDidEndDragging:self];
            
            break;
            
        case UIGestureRecognizerStateFailed:
            break;
            
        case UIGestureRecognizerStateCancelled:
            if ([_delegate respondsToSelector:@selector(swipeyCellDidEndDragging:)])
                [_delegate swipeyCellDidEndDragging:self];
            break;
            
        case UIGestureRecognizerStatePossible:
            break;
            
        default:
            break;
    }
}

// -----------------------------
// Enable the gesture only if
// it's a horizontal pan
// -----------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer respondsToSelector:@selector(velocityInView:)])
    {
        CGPoint velocity = [gestureRecognizer velocityInView:self.contentView.superview];
        if ( ABS(velocity.x) > ABS(velocity.y) && velocity.x < 0)
            return YES;
    }
    return NO;
}

// -----------------------------
// Ensure that we can scroll the
// table while dragging the cell
// -----------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// -----------------------------
// Convenience methods for cell
// reposition to common points
// -----------------------------
- (void)resetCellWithAnimation:(BOOL)animated
{
    [self setCellPosition:CGPointMake(0, 0) withAnimation:animated duration:0.25];
}

- (void)dismissCellWithAnimation:(BOOL)animated velocity:(CGPoint)velocity
{
    CGPoint dismissedPoint = CGPointMake(-self.frame.size.width, 0);
    CGFloat duration = ABS( (dismissedPoint.x - _swipeyView.frame.origin.x) / velocity.x);
    duration = MIN(duration, 0.4);
    [self setCellPosition:dismissedPoint withAnimation:animated duration:duration];
}

// -----------------------------
// Reposition the cell with or
// without animation
// -----------------------------
- (void)setCellPosition:(CGPoint)position withAnimation:(BOOL)animated duration:(CGFloat)duration
{
    CGFloat totalDuration = animated ? duration : 0.0;
    CGFloat bounceBack = 0.05;
    
    // Determine how far the cell needs to travel
    CGFloat distance = ABS(_swipeyView.frame.origin.x) - position.x;
    CGFloat bounceDistance = distance * bounceBack;
    
    // Determine the new positions
    CGPoint bouncePosition = CGPointMake(position.x + bounceDistance, 0);
    CGRect initialFrame = _swipeyView.frame;
    initialFrame.origin.x = bouncePosition.x;
    
    CGRect finalFrame = _swipeyView.frame;
    finalFrame.origin.x = position.x;
    
    // Animate the change of position
    [UIView animateWithDuration:totalDuration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                     animations:^{
                         _swipeyView.frame = initialFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:totalDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                                          animations:^{
                                              _swipeyView.frame = finalFrame;
                                          }
                                          completion:^(BOOL finished){}];
                     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
