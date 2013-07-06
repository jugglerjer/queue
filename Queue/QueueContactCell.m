//
//  QueueContactCell.m
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueContactCell.h"
#import "Contact.h"
#import "UIImage+Resize.h"

#define INSTRUCTION_IMAGE_HEIGHT        22.5
#define INSTRUCTION_IMAGE_WIDTH         28.0
#define INSTRUCTION_IMAGE_MARGIN_LEFT   21.0
#define INSTRUCTION_IMAGE_MARGIN_TOP    23.0

#define SNOOZE_LABEL_WIDTH              160.0

#define SNOOZE_IMAGE_WIDTH              28.0
#define SNOOZE_IMAGE_HEIGHT             25.0
#define SNOOZE_IMAGE_MARGIN_RIGHT       26.0
#define SNOOZE_IMAGE_MARGIN_TOP         23.5

@interface QueueContactCell ()

@property (strong, nonatomic) UIView *queueInstructionView;
@property (strong, nonatomic) UIImageView *queueInstructionImageView;
@property (strong, nonatomic) UILabel *queueInstructionLabel;
@property (strong, nonatomic) UIView *snoozeView;
@property (strong, nonatomic) UILabel *snoozeLabel;
@property (strong, nonatomic) UIImageView *snoozeImageView;
@property (strong, nonatomic) UIImageView *snoozeWell;
@property (strong, nonatomic) UIImage *placeholder;

@end

@implementation QueueContactCell

double queueDistance = 0.75;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {        
//        self.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1.0];
        self.clipsToBounds = NO;
        
        // Swipe Instruction View
        UIView *queueInstructionView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width + (0),
                                                                                                         self.bounds.origin.y, self.frame.size.width,
                                                                                                         self.frame.size.height)];
//        queueInstructionView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1.0];
        self.queueInstructionView = queueInstructionView;
        
        UIImageView *queueInstructionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(INSTRUCTION_IMAGE_MARGIN_LEFT, INSTRUCTION_IMAGE_MARGIN_TOP,
                                                                                               INSTRUCTION_IMAGE_WIDTH, INSTRUCTION_IMAGE_HEIGHT)];
        queueInstructionImageView.image = [UIImage imageNamed:@"check-finished.png"];
        self.queueInstructionImageView = queueInstructionImageView;
        
        UILabel *queueInstructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(INSTRUCTION_IMAGE_MARGIN_LEFT * 2 + INSTRUCTION_IMAGE_WIDTH,
                                                                                   26.0f, 160.0f, 22.0f)];
        queueInstructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
//        queueInstructionLabel.textColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0];
        queueInstructionLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4];
        queueInstructionLabel.shadowColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
        queueInstructionLabel.shadowOffset = CGSizeMake(0, -0.5);
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
        
        // Set up queue gesture recognizer
        UIPanGestureRecognizer *queueGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        queueGesture.delegate = self;
        [self.contentView addGestureRecognizer:queueGesture];
        
        // TODO Contact Photo
        QueueContactImageView *contactImage = [[QueueContactImageView alloc] initWithFrame:CGRectMake(11.0f, 11.0f, 52.0f, 52.0f)];
        contactImage.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
        contactImage.delegate = self;
        contactImage.marginLeft = 11.0f;
        
        self.placeholder = [UIImage imageNamed:@"contact-avatar-placeholder-clean.png"];
        
        // Snooze view
        // to be shown when the user is dragging the contact image in order to snooze the contact
        UIView *snoozeView = [[UIView alloc] initWithFrame:self.frame];
        snoozeView.alpha = 0.0;
        
        UIImageView *snoozeWell = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snooze-well.png"]];
        self.snoozeWell = snoozeWell;
        [snoozeView addSubview:snoozeWell];
        
        UILabel *snoozeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - SNOOZE_LABEL_WIDTH)/2,
                                                                         26.0f, SNOOZE_LABEL_WIDTH, 22.0f)];
        snoozeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        snoozeLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4];
        snoozeLabel.shadowColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
        snoozeLabel.shadowOffset = CGSizeMake(0, -0.5);
        snoozeLabel.backgroundColor = [UIColor clearColor];
        snoozeLabel.textAlignment = NSTextAlignmentCenter;
//        snoozeLabel.text = [self setSnoozeText];
        self.snoozeLabel = snoozeLabel;
        [snoozeView addSubview:self.snoozeLabel];
        
        UIImageView *snoozeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snooze-drop.png"]];
        snoozeImageView.frame = CGRectMake(self.frame.size.width - SNOOZE_IMAGE_MARGIN_RIGHT - SNOOZE_IMAGE_WIDTH,
                                           SNOOZE_IMAGE_MARGIN_TOP, SNOOZE_IMAGE_WIDTH, SNOOZE_IMAGE_HEIGHT);
        self.snoozeImageView = snoozeImageView;
        [snoozeView addSubview:self.snoozeImageView];
        
//        UIPanGestureRecognizer *snoozeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.contactImage action:@selector(handleGesture:)];
//        snoozeGesture.delegate = self;
//        [self.contactImage addGestureRecognizer:snoozeGesture];
        
        self.snoozeView = snoozeView;
        self.contactImage = contactImage;
        self.dueDateLabel = dueDateLabel;
        self.unitsLabel = unitsLabel;
        self.statusLabel = statusLabel;
        self.dueLabel = dueLabel;
        
        [self.contentView addSubview:self.snoozeView];
        [self.contentView addSubview:self.contactImage];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.dueDateLabel];
        [self.contentView addSubview:self.unitsLabel];
        [self.contentView addSubview:self.statusLabel];
        [self.contentView addSubview:self.dueLabel];
        
        self.selectionStyle = UITableViewCellEditingStyleNone;
    }
    return self;
}

- (UIImage *)avatarImageForContact:(Contact *)contact
{
    UIImage *image = [contact thumbnail];
    if (!image)
        image = _placeholder;
    else
        image = [image thumbnailImage:102
                    transparentBorder:0
                         cornerRadius:8
                 interpolationQuality:kCGInterpolationHigh];
    return [self.contactImage imageWithGloss:image];
}

- (void)setAvatarImageForContact:(Contact *)contact
{
    UIImage *image = [self avatarImageForContact:contact];
    self.contactImage.image = image;
    if ([_delegate respondsToSelector:@selector(queueContactCell:didSetImage:forContact:)])
        [_delegate queueContactCell:self didSetImage:image forContact:contact];
}

- (void)configureWithContact:(Contact *)contact andImage:(UIImage *)image
{       
    
    // TODO Contact Photo
    if (!image)
        image = _placeholder;
    self.contactImage.image = image;
    
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
                [self updateBackgroundWell];
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
//    NSLog(@"%@", otherGestureRecognizer);
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
    return [self percentageDraggedWithDragPoint:CGPointMake(self.contentView.bounds.origin.x, 0)];
}

// -----------------------------
// Determine how far the cell has
// been dragged relative to the threshold
// with a given drag point
// -----------------------------
- (CGFloat)percentageDraggedWithDragPoint:(CGPoint)dragPoint
{
    return ABS(dragPoint.x) / (self.frame.size.width * queueDistance);
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
    
    // Update the background well
    CGRect queueWellFrame = [self backgroundWellFrameForDragPoint:CGPointMake(bounds.origin.x, 0)];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.contentView.bounds = bounds;
                         self.backgroundWell.frame = queueWellFrame;
                     }
                     completion:^(BOOL finished){
                         if ([_delegate respondsToSelector:@selector(queueContactCell:didDismissWithType:)])
                             [_delegate queueContactCell:self didDismissWithType:QueueContactCellDismissalTypeQueue];
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
    
    CGRect instructionFrame = self.queueInstructionView.frame;
    instructionFrame.origin.x = [self instructionPositionWithDragPoint:position];
    CGRect queueWellFrame =  [self backgroundWellFrameForDragPoint:position];
    
    CGRect finalBounds = self.contentView.bounds;
    finalBounds.origin.x = position.x;
    
    // Determine the duration of the animation
    CGFloat initialDuration = ABS((distance / totalDistance) * totalDuration);
//    CGFloat bounceDuration = initialDuration * bounceBack;
//    NSLog(@"%f, %f", initialDuration, bounceDuration);
    
    // Animate the change of position
    [UIView animateWithDuration:totalDuration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.contentView.bounds = initialBounds;
                         self.backgroundWell.frame =  queueWellFrame;
                         self.queueInstructionView.frame = instructionFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:totalDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                                          animations:^{
                                              self.contentView.bounds = finalBounds;
                                          }
                                          completion:^(BOOL finished){}];
                     }];
}

// -----------------------------
// Change the size of the background
// well to reflect the cell's position
// -----------------------------
- (void)updateBackgroundWell
{
    self.backgroundWell.frame = [self backgroundWellFrameForDragPoint:CGPointMake(self.contentView.bounds.origin.x, 0)];
}

- (CGRect)backgroundWellFrameForDragPoint:(CGPoint)dragPoint
{
    return CGRectMake(self.contentView.frame.size.width - dragPoint.x,
                      dragPoint.y,
                      dragPoint.x,
                      self.contentView.frame.size.height);
}

// -----------------------------
// Determine instruction position
// based on cell dragging
// -----------------------------
- (CGFloat)instructionPosition
{
    return [self instructionPositionWithDragPoint:CGPointMake(self.contentView.bounds.origin.x, 0)];
}

// -----------------------------
// Determine instruction position
// based any given cell dragging point
// -----------------------------
- (CGFloat)instructionPositionWithDragPoint:(CGPoint)dragPoint
{
    CGFloat instructionStartingPoint = self.frame.size.width + (0);
    CGFloat instructionEndingPoint = self.frame.size.width * (1 - queueDistance);
    CGFloat totalInstructionDistance = instructionStartingPoint - instructionEndingPoint;
    
    CGFloat instructionDragPercentage = [self percentageDraggedWithDragPoint:dragPoint] <= 1.0 ? [self percentageDraggedWithDragPoint:dragPoint] : 1.0;
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

# pragma mark - Snoozing Methods
- (void)queueContactImageViewDidBeginDragging:(QueueContactImageView *)imageView
{
    [self showSnoozeTrackWithAnimation:YES];
    if ([_delegate respondsToSelector:@selector(queueContactCellDidBeginDragging:)])
        [_delegate queueContactCellDidBeginDragging:self];
}

- (void)queueContactImageView:(QueueContactImageView *)imageView didEndDraggingWithSnooze:(BOOL)snooze
{
    if (snooze)
    {
        if ([_delegate respondsToSelector:@selector(queueContactCell:didDismissWithType:)])
            [_delegate queueContactCell:self didDismissWithType:QueueContactCellDismissalTypeSnooze];
    }
    
    [self hideSnoozeTrackWithAnimation:YES];
    if ([_delegate respondsToSelector:@selector(queueContactCellDidEndDragging:)])
        [_delegate queueContactCellDidEndDragging:self];
}

- (void)queueContactImageView:(QueueContactImageView *)imageView canSnooze:(BOOL)snooze
{
    if (snooze)
        self.snoozeLabel.text = @"Release to snooze";
    else
        self.snoozeLabel.text = @"Slide to snooze";
    
}

- (void)queueContactImageViewWillSnooze:(QueueContactImageView *)imageView
{
    self.snoozeLabel.text = @"Snoozed";
}

- (void)showSnoozeTrackWithAnimation:(BOOL)animate
{
    [self setSnoozeTrackAlpha:1.0 animated:animate];
}

- (void)hideSnoozeTrackWithAnimation:(BOOL)animate
{
    [self setSnoozeTrackAlpha:0.0 animated:animate];
}

- (void)setSnoozeTrackAlpha:(CGFloat)alpha animated:(BOOL)animated
{
    CGFloat reverseAlpha = 1.0 - alpha;
    CGFloat duration = animated ? 0.25 : 0.0;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         // Adjust the snooze track
                         self.snoozeView.alpha = alpha;
                         
                         // Adjust the cell labels
                         self.nameLabel.alpha = reverseAlpha;
                         self.dueDateLabel.alpha = reverseAlpha;
                         self.statusLabel.alpha = reverseAlpha;
                         self.unitsLabel.alpha = reverseAlpha;
                         self.dueLabel.alpha = reverseAlpha;
                     }];
}

//- (NSString *)setSnoozeText
//{
//    return @"Slide to snooze";
//}

@end
