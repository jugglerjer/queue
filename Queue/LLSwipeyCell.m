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
        // Add pan gesture recognizer for swiping
        UIPanGestureRecognizer *queueGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        queueGesture.delegate = self;
        [self.contentView addGestureRecognizer:queueGesture];
    }
    return self;
}

// -----------------------------
// Handle dragging the cell left
// in order to queue the contact
// -----------------------------
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint distance = [gestureRecognizer translationInView:self.contentView.superview];
    CGRect bounds;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([_delegate respondsToSelector:@selector(swipeyCellDidBeginDragging:)])
                [_delegate swipeyCellDidBeginDragging:self];
            break;
            
        case UIGestureRecognizerStateChanged:
            bounds = self.contentView.bounds;
            
            if (distance.x < 0)
            {
                bounds.origin.x = -distance.x;
                [self.contentView setBounds:bounds];
            }
            
            if ([_delegate respondsToSelector:@selector(swipeyCellDidDrag:)])
                [_delegate swipeyCellDidDrag:self];
            
            break;
            
        case UIGestureRecognizerStateEnded:
            if (distance.x > _dragThreshold)
                [self dismissCellWithAnimation:YES andVelocity:[gestureRecognizer velocityInView:self.contentView.superview]];
            else
                [self resetCellPositionWithAnimation:YES];
            
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
