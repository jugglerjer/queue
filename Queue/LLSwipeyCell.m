//
//  LLSwipeyCell.m
//  Queue
//
//  Created by Jeremy Lubin on 7/27/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLSwipeyCell.h"

@implementation LLSwipeyCell

- (id)initWithDetailType:(LLSwipeyCellDetailType)detailType reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _detailType = detailType;
        
        CGRect underViewFrame = self.bounds;
        if (detailType == LLSwipeyCellDetailTypeAdjacent)
            underViewFrame.origin.x = underViewFrame.origin.x + self.frame.size.width;
        
        _underView = [[UIView alloc] initWithFrame:underViewFrame];
        _swipeyView = [[UIView alloc] initWithFrame:self.bounds];
        
        [self addSubview:_underView];
        [self addSubview:_swipeyView];
        
        // Add pan gesture recognizer for swiping
        UIPanGestureRecognizer *queueGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        queueGesture.delegate = self;
        [_swipeyView addGestureRecognizer:queueGesture];
        
        // Set initial properites
        _swipingEnabled = YES;
        _dragThreshold = self.frame.size.width / 2.0;
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
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _isDragging = YES;
            
            if ([_delegate respondsToSelector:@selector(swipeyCellDidBeginDragging:)])
                [_delegate swipeyCellDidBeginDragging:self];
            break;
            
        case UIGestureRecognizerStateChanged:            
            if (distance.x < 0)
                [self setSwipeOffset:CGPointMake(distance.x, 0)];
            
            if ([_delegate respondsToSelector:@selector(swipeyCellDidDrag:)])
                [_delegate swipeyCellDidDrag:self];
            if ([_delegate respondsToSelector:@selector(swipeyCell:didDragToPoint:)])
                [_delegate swipeyCell:self didDragToPoint:CGPointMake(distance.x, 0)];
            
            break;
            
        case UIGestureRecognizerStateEnded:
            _isDragging = NO;
            
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
            _isDragging = NO;
            
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
    if (!_swipingEnabled)
        return NO;
    
    if ([gestureRecognizer respondsToSelector:@selector(velocityInView:)])
    {
        CGPoint velocity = [gestureRecognizer velocityInView:self.swipeyView.superview];
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
// Stop the pan gesture when the
// cell has crossed its threshold
// -----------------------------
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
//    if ([panGesture respondsToSelector:@selector(translationInView:)])
//    {
//        if ([self hasCrossedQueueThresholdWithPoint:[panGesture translationInView:self.swipeyView.superview]])
//            return NO;
//    }
//    return YES;
//}

// -----------------------------
// Determine whether the cell
// has been dragged past its
// queue threshold
// -----------------------------
- (BOOL)hasCrossedQueueThresholdWithPoint:(CGPoint)point
{
    if (ABS(point.x) > _dragThreshold)
        return YES;
    return NO;
    
}

// -----------------------------
// Determine how far the cell has
// been dragged relative to the threshold
// -----------------------------
- (CGFloat)percentageDragged
{
    return [self percentageDraggedWithDragPoint:CGPointMake(_swipeyView.bounds.origin.x, 0)];
}

// -----------------------------
// Determine how far the cell has
// been dragged relative to the threshold
// with a given drag point
// -----------------------------
- (CGFloat)percentageDraggedWithDragPoint:(CGPoint)dragPoint
{
    return ABS(dragPoint.x) / _dragThreshold;
}

// -----------------------------
// Move the cell along with the
// user's finger
// -----------------------------
- (void)setSwipeOffset:(CGPoint)offset
{
    CGRect frame = self.frame;
    frame.origin.x = offset.x;
    frame.origin.y = offset.y;
    [_swipeyView setFrame:frame];
    
    CGRect detailFrame = _underView.frame;
    if (_detailType == LLSwipeyCellDetailTypeAdjacent)
        detailFrame.origin.x = offset.x + frame.size.width;
    [_underView setFrame:detailFrame];
}

// -----------------------------
// Convenience methods for cell
// reposition to common points
// -----------------------------
- (void)resetCellWithAnimation:(BOOL)animated
{
    __weak LLSwipeyCell *this = self;
    [self setCellPosition:CGPointMake(0, 0) withAnimation:animated duration:0.25 completion:^{
        if ([this.delegate respondsToSelector:@selector(swipeyCellDidReset:)])
            [this.delegate swipeyCellDidReset:this];
    }];
    _isDismissed = NO;
}

- (void)dismissCellWithAnimation:(BOOL)animated velocity:(CGPoint)velocity
{
    CGPoint dismissedPoint = CGPointMake(-self.frame.size.width, 0);
    CGFloat duration = ABS( (dismissedPoint.x - _swipeyView.frame.origin.x) / velocity.x);
    duration = MIN(duration, 0.4);
    
    __weak LLSwipeyCell *this = self;
    [self setCellPosition:dismissedPoint withAnimation:animated duration:duration completion:^{
        if ([this.delegate respondsToSelector:@selector(swipeyCellDidDismiss:)])
            [this.delegate swipeyCellDidDismiss:this];
    }];
    _isDismissed = YES;
}

// -----------------------------
// Reposition the cell with or
// without animation
// -----------------------------
- (void)setCellPosition:(CGPoint)position withAnimation:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))block
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
    
    CGRect initialDetailFrame = _underView.frame;
    CGRect finalDetailFrame = _underView.frame;
    if (_detailType == LLSwipeyCellDetailTypeAdjacent)
    {
        initialDetailFrame.origin.x = bouncePosition.x + initialFrame.size.width;
        finalDetailFrame.origin.x = position.x + initialFrame.size.width;
    }
    
    // Animate the change of position
    [UIView animateWithDuration:totalDuration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                     animations:^{
                         _swipeyView.frame = initialFrame;
                         _underView.frame = initialDetailFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:totalDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                                          animations:^{
                                              _swipeyView.frame = finalFrame;
                                              _underView.frame = finalDetailFrame;
                                          }
                                          completion:^(BOOL finished){
                                              if (block)
                                                  block();
                                          }];
                     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.swipeyView setFrame:self.bounds];
    [self.underView setFrame:self.bounds];
}

@end
