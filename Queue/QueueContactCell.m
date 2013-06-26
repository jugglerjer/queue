//
//  QueueContactCell.m
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueContactCell.h"
#import "Contact.h"

@implementation QueueContactCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {        
        // Background View
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue-row-background.png"]];
        [self addSubview:backgroundView];
        
        // TODO Contact Photo
        UIImageView *contactImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact-avatar-placeholder.png"]];
        contactImage.frame = CGRectMake(11.0f, 11.0f, 52.0f, 52.0f);
        [self.contentView addSubview:contactImage];
        
        // Contact Name
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, 26.0f, 160.0f, 22.0f)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        nameLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel = nameLabel;
        [self.contentView addSubview:self.nameLabel];
        
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
        [self.contentView addGestureRecognizer:queueGesture];
        
        self.dueDateLabel = dueDateLabel;
        self.unitsLabel = unitsLabel;
        self.statusLabel = statusLabel;
        self.dueLabel = dueLabel;
        
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
    CGPoint distance;
    CGRect bounds;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"gesture detected");
            break;
            
        case UIGestureRecognizerStateChanged:
            distance = [gestureRecognizer translationInView:self.contentView.superview];
            bounds = self.contentView.bounds;
            if (distance.x < 0)
            {
                bounds.origin.x = -distance.x;
//                NSLog(@"%f", bounds.origin.x);
                [self.contentView setBounds:bounds];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            [self resetCellPositionWithAnimation:YES];
            break;
            
        default:
            [self resetCellPositionWithAnimation:YES];
            break;
    }
    
    
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
    
    CGRect finalBounds = self.contentView.bounds;
    finalBounds.origin.x = position.x;
    
    // Determine the duration of the animation
    CGFloat initialDuration = (distance / totalDistance) * totalDuration;
    CGFloat bounceDuration = initialDuration * bounceBack;
    NSLog(@"%f, %f", initialDuration, bounceDuration);
    
    // Animate the change of position
    [UIView animateWithDuration:initialDuration
                     animations:^{
                         self.contentView.bounds = initialBounds;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:bounceDuration
                                          animations:^{
                                              self.contentView.bounds = finalBounds;
                                          }];
                     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
