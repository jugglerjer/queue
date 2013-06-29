//
//  QueueContactCell.m
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueContactCell.h"
#import "Contact.h"

#define INSTRUCTION_IMAGE_HEIGHT        22.5
#define INSTRUCTION_IMAGE_WIDTH         28.0
#define INSTRUCTION_IMAGE_MARGIN_LEFT   21.0
#define INSTRUCTION_IMAGE_MARGIN_TOP    23.0

@interface QueueContactCell ()

@property (strong, nonatomic) UIView *queueInstructionView;
@property (strong, nonatomic) UIImageView *queueInstructionImageView;
@property (strong, nonatomic) UILabel *queueInstructionLabel;

@end

@implementation QueueContactCell

double queueDistance = 0.75;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {        
        self.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1.0];
        
        // Swipe Instruction View
        UIView *queueInstructionView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width + (0),
                                                                                                         self.bounds.origin.y, self.frame.size.width,
                                                                                                         self.frame.size.height)];
        self.queueInstructionView = queueInstructionView;
        
        UIImageView *queueInstructionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(INSTRUCTION_IMAGE_MARGIN_LEFT, INSTRUCTION_IMAGE_MARGIN_TOP,
                                                                                               INSTRUCTION_IMAGE_WIDTH, INSTRUCTION_IMAGE_HEIGHT)];
        queueInstructionImageView.image = [UIImage imageNamed:@"check-finished.png"];
        self.queueInstructionImageView = queueInstructionImageView;
        
        UILabel *queueInstructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(INSTRUCTION_IMAGE_MARGIN_LEFT * 2 + INSTRUCTION_IMAGE_WIDTH,
                                                                                   26.0f, 160.0f, 22.0f)];
        queueInstructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        queueInstructionLabel.textColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0];
        queueInstructionLabel.backgroundColor = [UIColor clearColor];
//        queueInstructionLabel.text = @"Slide to queue";
        self.queueInstructionLabel = queueInstructionLabel;
        
        [self.queueInstructionView addSubview:self.queueInstructionLabel];
        [self.queueInstructionView addSubview:self.queueInstructionImageView];
        [self addSubview:self.queueInstructionView];
        
        // Background View
        UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImageView *backgroundWell = [[UIImageView alloc] initWithImage:innerShadow];
        self.backgroundWell = backgroundWell;
        [self addSubview:backgroundWell];
        
        // Background Color
//        self.contentView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue-row-background.png"]];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
        [self.contentView addSubview:backgroundView];
        
        // Contact Name
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, 26.0f, 160.0f, 22.0f)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        nameLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel = nameLabel;
        
        // Contact Due Date & Unit Label
        UILabel *dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0f, 9.0f, 57.0f, 53.0f)];
        UILabel *unitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(276.0f, 20.0f, 37.0f, 10.0f)];
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(276.0f, 30.0f, 37.0f, 10.0f)];
        UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(276.0f, 40.0f, 37.0f, 10.0f)];
        
        dueDateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0];
        UIFont *statusLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        unitsLabel.font = statusLabelFont;
        statusLabel.font = statusLabelFont;
        dueLabel.font = statusLabelFont;
        
        dueDateLabel.textAlignment = NSTextAlignmentRight;
        
        dueDateLabel.backgroundColor = [UIColor clearColor];
        unitsLabel.backgroundColor = [UIColor clearColor];
        statusLabel.backgroundColor = [UIColor clearColor];
        dueLabel.backgroundColor = [UIColor clearColor];
        
        UIColor *statusColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0];
        statusLabel.textColor = statusColor;
        dueLabel.textColor = statusColor;
        
        // TODO Contact Photo
        UIImageView *contactImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact-avatar-placeholder.png"]];
        contactImage.frame = CGRectMake(11.0f, 11.0f, 52.0f, 52.0f);
        [self.contentView addSubview:contactImage];
        
        // Set up queue gesture recognizer
        UIPanGestureRecognizer *queueGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        queueGesture.delegate = self;
        [self.contentView addGestureRecognizer:queueGesture];
        
        self.dueDateLabel = dueDateLabel;
        self.unitsLabel = unitsLabel;
        self.statusLabel = statusLabel;
        self.dueLabel = dueLabel;
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.dueDateLabel];
        [self.contentView addSubview:self.unitsLabel];
        [self.contentView addSubview:self.statusLabel];
        [self.contentView addSubview:self.dueLabel];
        
        self.selectionStyle = UITableViewCellEditingStyleNone;
    }
    return self;
}

- (void)configureWithContact:(Contact *)contact
{       
    
    // TODO Contact Photo
    
    // Contact Name
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    
    // Contact Due Date & Unit Label
    double unitsUntilDue = [contact weeksUntilDue];

    self.dueLabel.text = @"DUE";
    
    if (unitsUntilDue == 1)
    {
        self.unitsLabel.text = @"WEEK";
    }
    else
    {
        self.unitsLabel.text = @"WEEKS";
    }
    
    if (unitsUntilDue >= 0)
    {
        UIColor *underDueColor = [UIColor colorWithRed:58.0/255.0 green:58.0/255.0 blue:58.0/255.0 alpha:1.0];
        self.dueDateLabel.textColor = underDueColor;
        self.unitsLabel.textColor = underDueColor;
        self.dueDateLabel.text = [NSString stringWithFormat:@"%.0f", [contact weeksUntilDue]];
        self.statusLabel.text = @"UNTIL";
    }
    else
    {
        UIColor *overDueColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.dueDateLabel.textColor = overDueColor;
        self.unitsLabel.textColor = overDueColor;
        self.dueDateLabel.text = [NSString stringWithFormat:@"%.0f", [contact weeksUntilDue] * -1];
        self.statusLabel.text = @"OVER";
    }
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
            NSLog(@"Gesture began");
            if ([_delegate respondsToSelector:@selector(queueContactCellDidBeginDragging:)])
                [_delegate queueContactCellDidBeginDragging:self];
            break;
            
        case UIGestureRecognizerStateChanged:
//            NSLog(@"Gesture changed");
            bounds = self.contentView.bounds;
            
            if (distance.x < 0)
            {
                bounds.origin.x = -distance.x;
                [self.contentView setBounds:bounds];
                [self updateInstructionView];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            NSLog(@"Gesture ended");
            if ([self gestureHasCrossedQueueThresholdWithPoint:distance])
            {
//                gestureRecognizer.enabled = NO;
                [self dismissCellWithAnimation:YES andVelocity:[gestureRecognizer velocityInView:self.contentView.superview]];
            }
            else
            {
                [self resetCellPositionWithAnimation:YES];
            }
            if ([_delegate respondsToSelector:@selector(queueContactCellDidEndDragging:)])
                [_delegate queueContactCellDidEndDragging:self];
            break;
            
        case UIGestureRecognizerStateFailed:
            NSLog(@"Gesture failed");
//            gestureRecognizer.enabled = YES;
            break;
            
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Gesture cencelled");
//            gestureRecognizer.enabled = YES;
            if ([_delegate respondsToSelector:@selector(queueContactCellDidEndDragging:)])
                [_delegate queueContactCellDidEndDragging:self];
            break;
            
        case UIGestureRecognizerStatePossible:
            NSLog(@"Gesture possible");
            break;
            
//        case UIGestureRecognizerStateRecognized:
//            NSLog(@"Gesture recognized");
//            break;
            
        default:
//            NSLog(@"default");
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
        return ABS(velocity.x) > ABS(velocity.y);
    }
    return YES;
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
//        if ([self gestureHasCrossedQueueThresholdWithPoint:[panGesture translationInView:self.contentView.superview]])
//            return NO;
//    }
//    return YES;
//}

// -----------------------------
// Determine whether the cell
// has been dragged past its
// queue threshold
// -----------------------------
- (BOOL)gestureHasCrossedQueueThresholdWithPoint:(CGPoint)point
{
    if (ABS(point.x) >= self.frame.size.width * queueDistance)
        return YES;
    return NO;

}

// -----------------------------
// Determine how far the cell has
// been dragged relative to the threshold
// -----------------------------
- (CGFloat)percentageDragged
{
    return ABS(self.contentView.bounds.origin.x) / (self.frame.size.width * queueDistance);
}

// -----------------------------
// Bounce the cell back into its
// initial position
// -----------------------------
- (void)resetCellPositionWithAnimation:(BOOL)animated
{
    [self setCellPosition:CGPointMake(0, 0) withAnimation:YES];
}

// -----------------------------
// Dismiss cell at the same velocity
// that it was dragged
// -----------------------------
- (void)dismissCellWithAnimation:(BOOL)animated andVelocity:(CGPoint)velocity
{
    // Determine how quickly to move the cell based on its velocity
//    NSLog(@"%f", self.contentView.bounds.origin.x);
    CGFloat distanceToTravel = /*self.frame.size.width - */ABS(self.contentView.bounds.origin.x);
    CGFloat duration = animated ? ABS(distanceToTravel / velocity.x) : 0.0;
    
    // Set a minimum duration
    duration = duration > 0.4 ? 0.4 : duration;
    
    // Generate the new content view position
    CGRect bounds = self.contentView.bounds;
    bounds.origin.x = self.frame.size.width;
    
    // Update the instruction view
    self.queueInstructionLabel.text = @"Queued";
    CGRect instructionCheckFrame = self.queueInstructionImageView.frame;
    CGFloat magnification = 0.2;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.contentView.bounds = bounds;
                     }
                     completion:^(BOOL finished){
                         if ([_delegate respondsToSelector:@selector(queueContactCellDidDismiss:)])
                             [_delegate queueContactCellDidDismiss:self];
                     }];
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.queueInstructionImageView.frame = CGRectMake(instructionCheckFrame.origin.x * (1 - magnification/2),
                                                                           instructionCheckFrame.origin.y * (1 - magnification/2),
                                                                           instructionCheckFrame.size.width * (1 + magnification),
                                                                           instructionCheckFrame.size.height * (1 + magnification));
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              self.queueInstructionImageView.frame = instructionCheckFrame;
                                          }];
                     }];
}

// -----------------------------
// Reposition the cell with or
// without animation
// -----------------------------
- (void)setCellPosition:(CGPoint)position withAnimation:(BOOL)animated
{    
    CGFloat totalDuration = 0.25;                        /* Total time that the animation would take if it were moving the full width of the screen */
    CGFloat totalDistance = self.contentView.frame.size.width;       /* Max distance the cell could need to travel */
    CGFloat bounceBack = 0.05;                           /* Percentage of distance to bounce for momentum */
    
    // Determine how far the cell needs to travel
    CGFloat distance = -self.contentView.bounds.origin.x - position.x;
    CGFloat bounceDistance = distance * bounceBack;
    
    // Determine the direction of travel
//    CGFloat direction = self.bounds.origin.x <= position.x ? 1.0 : -1.0;        /* 1.0: right, -1.0: left */
    
    // Determine the new positions
    CGPoint bouncePosition = CGPointMake(position.x + bounceDistance, 0);
    CGRect initialBounds = self.contentView.bounds;
    initialBounds.origin.x = bouncePosition.x;
    
//    CGFloat instructionBouncePosition;
    
    CGRect finalBounds = self.contentView.bounds;
    finalBounds.origin.x = position.x;
    
    // Determine the duration of the animation
    CGFloat initialDuration = (distance / totalDistance) * totalDuration;
    CGFloat bounceDuration = initialDuration * bounceBack;
//    NSLog(@"%f, %f", initialDuration, bounceDuration);
    
    // Animate the change of position
    [UIView animateWithDuration:initialDuration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.contentView.bounds = initialBounds;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:bounceDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              self.contentView.bounds = finalBounds;
                                          }
                                          completion:^(BOOL finished){}];
                     }];
}

// -----------------------------
// Determine instruction position
// based on cell dragging
// -----------------------------
- (CGFloat)instructionPosition
{
    CGFloat instructionStartingPoint = self.frame.size.width + (0);
    CGFloat instructionEndingPoint = self.frame.size.width * (1 - queueDistance);
    CGFloat totalInstructionDistance = instructionStartingPoint - instructionEndingPoint;
    
    CGFloat instructionDragPercentage = [self percentageDragged] <= 1.0 ? [self percentageDragged] : 1.0;
    return instructionStartingPoint - (totalInstructionDistance * instructionDragPercentage);
}

// -----------------------------
// Update the instruction view
// based on the cell dragging
// -----------------------------
- (void)updateInstructionView
{
    // Calculate the new position on the instruction view
//    CGFloat xPosition = self.frame.size.width - self.contentView.bounds.origin.x;
    
    CGRect newFrame = self.queueInstructionView.frame;
    newFrame.origin.x = [self instructionPosition];
    
    [self.queueInstructionView setFrame:newFrame];
    
    // Calculate the alpha for the check mark
//    CGFloat alpha = (self.frame.size.width - self.queueInstructionView.frame.origin.x) / (self.frame.size.width * queueDistance);
    self.queueInstructionImageView.alpha = [self percentageDragged];
    
    if ([self percentageDragged] >= 1.0)
        self.queueInstructionLabel.text = @"Release to queue";
    else
        self.queueInstructionLabel.text = @"Slide to queue";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
