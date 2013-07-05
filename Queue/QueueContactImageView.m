//
//  QueueContactImageView.m
//  Queue
//
//  Created by Jeremy Lubin on 6/30/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueContactImageView.h"
#import <QuartzCore/QuartzCore.h>  

@interface QueueContactImageView ()
{
    UIImageView *imageView;
    UIImage *gloss;
}
@end

@implementation QueueContactImageView

float shadowFlatOpacity = 0.1;
float shadowElevatedOpacity = 0.4;
float wellMarginRight = 10.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Create the image view
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView.layer setMinificationFilter:kCAFilterTrilinear];
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 8;
        [self addSubview:imageView];
        
        // Cache common images
        gloss = [UIImage imageNamed:@"avatar-gloss.png"];
        
        self.userInteractionEnabled = YES;
        
        // Add dragging gesture recognizer
        UIPanGestureRecognizer *snoozeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        snoozeGesture.delegate = self;
        [self addGestureRecognizer:snoozeGesture];
        
        // Add shadow
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.2;
        
        
    }
    return self;
}

// -----------------------------
// Ensure that we can detect drags
// on the image as well as the cell 
// -----------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// -----------------------------
// Enable the gesture only if
// it's a horizontal pan and to the
// right
// -----------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer respondsToSelector:@selector(velocityInView:)])
    {
        CGPoint velocity = [gestureRecognizer velocityInView:self.superview];
        if ( ABS(velocity.x) > ABS(velocity.y) && velocity.x > 0)
            return YES;
    }
    return NO;
}

// -----------------------------
// Handle dragging the image view
// in order to snooze the contact
// -----------------------------
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint distance = [gestureRecognizer translationInView:self.superview];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([_delegate respondsToSelector:@selector(queueContactImageViewDidBeginDragging:)])
                [_delegate queueContactImageViewDidBeginDragging:self];
            break;
            
        case UIGestureRecognizerStateChanged:            
            if (distance.x > 0 && distance.x < [self maxDragPosition])
            {
                CGPoint position = CGPointMake(distance.x + self.marginLeft, 0);
                [self setImagePosition:position animated:NO];
                [self showShadowWithAnimation:YES];
                if ([_delegate respondsToSelector:@selector(queueContactImageView:canSnooze:)])
                    [_delegate queueContactImageView:self canSnooze:[self isInSnoozeZone]];
                
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if ([self isInSnoozeZone])
            {
                if ([_delegate respondsToSelector:@selector(queueContactImageViewWillSnooze:)])
                    [_delegate queueContactImageViewWillSnooze:self];
                [self performSelector:@selector(resetImagePosition) withObject:nil afterDelay:0.4];
            }
            else
                [self performSelector:@selector(resetImagePosition) withObject:nil afterDelay:0.0];
            
            break;
            
        case UIGestureRecognizerStateFailed:
            break;
            
        case UIGestureRecognizerStateCancelled:
            break;
            
        case UIGestureRecognizerStatePossible:
            break;
            
        default:
            break;
    }
}

#pragma mark - Image Positioning Methods

// -----------------------------
// Set the imageView's image
// -----------------------------
- (void)setImage:(UIImage *)image
{
    imageView.image = image;
}

// -----------------------------
// Draw a new image with gloss
// -----------------------------
- (UIImage *)imageWithGloss:(UIImage *)image
{
    CGSize size = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [gloss drawAtPoint:CGPointZero];
    UIImage *imageWithGloss = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageWithGloss;
}

// -----------------------------
// Reset the image to its
// initial position
// -----------------------------
- (void)resetImagePosition
{
    if ([_delegate respondsToSelector:@selector(queueContactImageView:didEndDraggingWithSnooze:)])
        [_delegate queueContactImageView:self didEndDraggingWithSnooze:[self isInSnoozeZone]];
    CGPoint position = CGPointMake(self.marginLeft, 0);
    [self setImagePosition:position animated:YES];
    [self hideShadowWithAnimation:YES];
}

// -----------------------------
// Change the image position
// according the user's dragging
// -----------------------------
- (void)setImagePosition:(CGPoint)position animated:(BOOL)animated
{
    CGFloat totalDuration = 0.25;                        /* Total time that the animation would take if it were moving the full width of the screen */
    CGFloat totalDistance = 320 - self.frame.size.width - self.marginLeft - wellMarginRight;       /* Max distance the cell could need to travel */
    CGFloat bounceBack = 0.025;                           /* Percentage of distance to bounce for momentum */
    
    // Determine how far the cell needs to travel
    CGFloat distance = ABS(self.frame.origin.x - position.x);
    CGFloat bounceDistance = distance * bounceBack;
    
    // Determine the direction of travel
    //    CGFloat direction = self.bounds.origin.x <= position.x ? 1.0 : -1.0;        /* 1.0: right, -1.0: left */
    
    // Determine the new positions
    CGPoint bouncePosition = CGPointMake(position.x - bounceDistance, 0);
    CGRect initialFrame = self.frame;
    initialFrame.origin.x = bouncePosition.x;
    
    CGRect finalFrame = self.frame;
    finalFrame.origin.x = position.x;
    
    // Determine the duration of the animation
    CGFloat initialDuration = animated ? (distance / totalDistance) * totalDuration : 0.0;
    CGFloat bounceDuration = initialDuration * bounceBack;
    
//    CGRect frame = self.frame;
//    frame.origin.x = position.x;
//    
//    CGRect bounceFrame = self.frame;
//    CGFloat bounceDistance = 0.1 * position.x;
//    bounceFrame.origin.x = self.frame.origin.x > position.x ? position.x - bounceDistance : position.x + bounceDistance;
//    
//    CGFloat duration = animated ? 0.25 : 0.0;
//    CGFloat bounceDuration = 
    
    [UIView animateWithDuration:totalDuration
                          delay: 0.0
                        options: UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.frame = animated ? initialFrame : finalFrame;
                     } completion:^(BOOL finished){
                         if (animated)
                             [UIView animateWithDuration:totalDuration
                                                   delay: 0.0
                                                 options: UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                                              animations:^{
                                                  self.frame = finalFrame;
                                              } completion:^(BOOL finished){}];
                     }];
}

// -----------------------------
// Return the image's maximum
// drag position
// -----------------------------
- (CGFloat)maxDragPosition
{
    return 320 - wellMarginRight*2 - self.frame.size.width;
}

// -----------------------------
// Determine whether the image
// has been dragged into the
// snooze zone
// -----------------------------
- (BOOL)isInSnoozeZone
{
    if (self.frame.origin.x > [self maxDragPosition])
    {
        NSLog(@"In snooze zone");
        return YES;
    }
    return NO;
}

#pragma mark - Shadow Methods

// -----------------------------
// Reveal the image's drop shadow
// for an elevated appearance
// -----------------------------
- (void)showShadowWithAnimation:(BOOL)animated
{
    [self setShadowOpacity:shadowElevatedOpacity animated:animated];
}

// -----------------------------
// Hide the image's drop shadow
// for a flat appearance
// -----------------------------
- (void)hideShadowWithAnimation:(BOOL)animated
{
    [self setShadowOpacity:shadowFlatOpacity animated:animated];
}

// -----------------------------
// Animate a change to the image's
// drop shadow
// -----------------------------
- (void)setShadowOpacity:(float)opacity animated:(BOOL)animated
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:self.layer.shadowOpacity];
    anim.toValue = [NSNumber numberWithFloat:opacity];
    anim.duration = animated ? 0.25 : 0.0;
    [self.layer addAnimation:anim forKey:@"shadowOpacity"];
    self.layer.shadowOpacity = opacity;
}

@end
