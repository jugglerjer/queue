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
#import "Location.h"
#import "Meeting.h"
#import "UIView+NearestViewController.h"

#define INSTRUCTION_IMAGE_HEIGHT        31.0
#define INSTRUCTION_IMAGE_WIDTH         31.0
#define INSTRUCTION_IMAGE_MARGIN        11.0

#define INSTRUCTION_LABEL_MARGIN_TOP    18.0
#define INSTRUCTION_LABEL_HEIGHT        18.0

#define SNOOZE_LABEL_WIDTH              160.0

#define SNOOZE_IMAGE_WIDTH              28.0
#define SNOOZE_IMAGE_HEIGHT             25.0
#define SNOOZE_IMAGE_MARGIN_RIGHT       26.0
#define SNOOZE_IMAGE_MARGIN_TOP         23.5

@interface QueueContactCell ()

@property (strong, nonatomic) UIControl *queueInstructionControl;
@property (strong, nonatomic) UIImageView *queueInstructionImageView;
@property (strong, nonatomic) UIButton *confirmMeetingButton;
@property (strong, nonatomic) UIButton *cancelMeetingButton;
@property (strong, nonatomic) UILabel *meetingDateLabel;
@property (strong, nonatomic) UILabel *meetingLocationLabel;
@property (strong, nonatomic) UILabel *queueInstructionLabel;
@property (strong, nonatomic) UIView *snoozeView;
@property (strong, nonatomic) UILabel *snoozeLabel;
@property (strong, nonatomic) UIImageView *snoozeImageView;
@property (strong, nonatomic) UIImageView *snoozeWell;
@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) Meeting *meeting;
@property (strong, nonatomic) Location *location;

@end

@implementation QueueContactCell

double queueDistance = 0.75;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithDetailType:LLSwipeyCellDetailTypeUnderneath reuseIdentifier:reuseIdentifier];
    if (self)
    {        
        self.clipsToBounds = NO;
        
        // Register for meeting default location updates
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(configureWithDefaultLocation:)
                                                     name:@"DefaultLocationDidChange"
                                                   object:nil];
        
        // Swipe Instruction View
        
        // Set the threshold after which the event is deleted on drag
        self.dragThreshold = self.frame.size.width * 0.75;
        
        _cancelMeetingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelMeetingButton.frame = CGRectMake(21.5,
                                                (72.0 - INSTRUCTION_IMAGE_HEIGHT)/2,
                                                INSTRUCTION_IMAGE_WIDTH,
                                                INSTRUCTION_IMAGE_HEIGHT);
        [_cancelMeetingButton setImage:[UIImage imageNamed:@"cancel-delete-meeting.png"] forState:UIControlStateNormal];
        _cancelMeetingButton.showsTouchWhenHighlighted = YES;
        [_cancelMeetingButton addTarget:self action:@selector(cancelCreateMeeting) forControlEvents:UIControlEventTouchUpInside];
        
        _queueInstructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 26.0f, 180.0f, 22.0f)];
        _queueInstructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        _queueInstructionLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
//        _queueInstructionLabel.shadowColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
//        _queueInstructionLabel.shadowOffset = CGSizeMake(0, -0.5);
        _queueInstructionLabel.backgroundColor = [UIColor clearColor];
        _queueInstructionLabel.text = @"Met up today at Mission Beach Cafe";
        
        _confirmMeetingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmMeetingButton.frame = CGRectMake(self.frame.size.width - INSTRUCTION_IMAGE_WIDTH - INSTRUCTION_IMAGE_MARGIN,
                                                 (72.0 - INSTRUCTION_IMAGE_HEIGHT)/2, INSTRUCTION_IMAGE_WIDTH, INSTRUCTION_IMAGE_HEIGHT);
        [_confirmMeetingButton setImage:[UIImage imageNamed:@"confirm-meeting.png"] forState:UIControlStateNormal];
        _confirmMeetingButton.showsTouchWhenHighlighted = YES;
        [_confirmMeetingButton addTarget:self action:@selector(confirmCreateMeeting) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect meetingLabelFrame = CGRectMake(74.0,
                                              INSTRUCTION_LABEL_MARGIN_TOP,
                                              self.frame.size.width - INSTRUCTION_IMAGE_WIDTH*2 - INSTRUCTION_IMAGE_MARGIN - 74.0,
                                              INSTRUCTION_LABEL_HEIGHT);
        UIFont *meetingLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
        UIColor *meetingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
        
        _meetingDateLabel = [[UILabel alloc] initWithFrame:meetingLabelFrame];
        _meetingDateLabel.font = meetingLabelFont;
        _meetingDateLabel.textColor = meetingLabelTextColor;
        _meetingDateLabel.backgroundColor = [UIColor clearColor];
        
        _meetingLocationLabel = [[UILabel alloc] initWithFrame:meetingLabelFrame];
        _meetingLocationLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        _meetingLocationLabel.textColor  = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1];
        _meetingLocationLabel.backgroundColor = [UIColor clearColor];
        
        _queueInstructionControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.underView.frame.size.width, self.underView.frame.size.height)];
        [_queueInstructionControl addTarget:self action:@selector(editMeeting) forControlEvents:UIControlEventTouchUpInside];
        
        [self.underView addSubview:_queueInstructionControl];
        [self.underView addSubview:_meetingDateLabel];
        [self.underView addSubview:_meetingLocationLabel];
        [self.underView addSubview:_confirmMeetingButton];
        [self.underView addSubview:_cancelMeetingButton];
        
        // Background View
        UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImageView *backgroundWell = [[UIImageView alloc] initWithImage:innerShadow];
        self.backgroundWell = backgroundWell;
        [self.underView addSubview:backgroundWell];
        
        // Background Color
//        self.contentView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue-row-background.png"]];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
        [self.swipeyView addSubview:backgroundView];
        
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
        
        self.snoozeView = snoozeView;
        self.contactImage = contactImage;
        self.dueDateLabel = dueDateLabel;
        self.unitsLabel = unitsLabel;
        self.statusLabel = statusLabel;
        self.dueLabel = dueLabel;
        
        [self.swipeyView addSubview:self.snoozeView];
        [self.swipeyView addSubview:self.contactImage];
        [self.swipeyView addSubview:self.nameLabel];
        [self.swipeyView addSubview:self.dueDateLabel];
        [self.swipeyView addSubview:self.unitsLabel];
        [self.swipeyView addSubview:self.statusLabel];
        [self.swipeyView addSubview:self.dueLabel];
        
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
    if ([self.delegate respondsToSelector:@selector(queueContactCell:didSetImage:forContact:)])
        [self.delegate queueContactCell:self didSetImage:image forContact:contact];
}

- (void)configureWithContact:(Contact *)contact andImage:(UIImage *)image
{       
    
    _contact = contact;
    
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

- (void)configureWithMeeting:(Meeting *)meeting
{
    if (![_meeting isEqual:meeting])
        _meeting = meeting;
    
    // Allocate the positioning variables for the date and location
    CGRect newDateFrame = _meetingDateLabel.frame;
    CGRect newLocationFrame = _meetingLocationLabel.frame;
    
    // Meeting date
    NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
    [meetingDateFormatter setDateFormat:@"EEE, MMM d"];
    _meetingDateLabel.text = [NSString stringWithFormat:@"Add meeting on %@", [meetingDateFormatter stringFromDate:_meeting.date]];
    
    // Meeting location
    if (_meeting.location)
    {
        _meetingLocationLabel.text = [NSString stringWithFormat:@"at %@, %@", [_meeting.location title], [_meeting.location subtitle]];
        
        // Generate the necessary positioning for the date and location
        newDateFrame.origin.y = INSTRUCTION_LABEL_MARGIN_TOP;
        newLocationFrame.origin.y = INSTRUCTION_LABEL_MARGIN_TOP + INSTRUCTION_LABEL_HEIGHT;
        newLocationFrame.size.height = INSTRUCTION_LABEL_HEIGHT;
    }
    else
    {
        // Generate the necessary positioning for the date and location
        newDateFrame.origin.y = INSTRUCTION_LABEL_MARGIN_TOP + INSTRUCTION_LABEL_HEIGHT/2;
        newLocationFrame.size.height = 0.0;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_meetingDateLabel setFrame:newDateFrame];
                         [_meetingLocationLabel setFrame:newLocationFrame];
                     }
                     completion:nil];
}

- (void)configureWithDefaultLocation:(NSNotification *)notification
{
    _meeting.location = (Location *)[notification object];
    [self configureWithMeeting:_meeting];
}

// -----------------------------
// Show the meeting editor
// -----------------------------
- (void)editMeeting
{
    if ([self.delegate respondsToSelector:@selector(queueContactCell:didRequestMeetingEditWithMeeting:)])
        [self.delegate queueContactCell:self didRequestMeetingEditWithMeeting:_meeting];
}

// -----------------------------
// Update the background well
// as we slide the contact
// -----------------------------
- (void)setSwipeOffset:(CGPoint)offset
{
    [super setSwipeOffset:offset];
    
    [self updateBackgroundWell];
}

- (void)setCellPosition:(CGPoint)position withAnimation:(BOOL)animated duration:(CGFloat)duration
{
    [super setCellPosition:position withAnimation:animated duration:duration];
    CGFloat totalDuration = animated ? duration : 0.0;
    [UIView animateWithDuration:totalDuration delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut
                     animations:^{
                         _backgroundWell.frame = [self backgroundWellFrameForDragPoint:position];
                     }
                     completion:nil];
}

// -----------------------------
// Change the size of the background
// well to reflect the cell's position
// -----------------------------
- (void)updateBackgroundWell
{
    self.backgroundWell.frame = [self backgroundWellFrameForDragPoint:CGPointMake(self.swipeyView.frame.origin.x, 0)];
}

- (CGRect)backgroundWellFrameForDragPoint:(CGPoint)dragPoint
{
    return CGRectMake(self.swipeyView.frame.size.width - ABS(dragPoint.x),
                      dragPoint.y,
                      ABS(dragPoint.x),
                      self.swipeyView.frame.size.height);
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
//- (void)updateInstructionView
//{
//    // Calculate the new position on the instruction view
////    CGFloat xPosition = self.frame.size.width - self.contentView.bounds.origin.x;
//    
//    CGRect newFrame = self.queueInstructionView.frame;
//    newFrame.origin.x = [self instructionPosition];
//    
//    [self.queueInstructionView setFrame:newFrame];
//    
//    // Calculate the alpha for the check mark
////    CGFloat alpha = (self.frame.size.width - self.queueInstructionView.frame.origin.x) / (self.frame.size.width * queueDistance);
//    self.queueInstructionImageView.alpha = [self percentageDragged];
//    
//    if ([self percentageDragged] >= 1.0)
//        self.queueInstructionLabel.text = @"Release to queue";
//    else
//        self.queueInstructionLabel.text = @"Slide to queue";
//}

// -----------------------------
// Cancel the swipe to queue UI
// -----------------------------
- (void)cancelCreateMeeting
{
    [self resetCellWithAnimation:YES];
}

// -----------------------------
// Add a new meeting with the
// current settings
// -----------------------------
- (void)confirmCreateMeeting
{
    if ([self.delegate respondsToSelector:@selector(queueContactCell:didDismissWithType:andMeeting:)])
        [self.delegate queueContactCell:self didDismissWithType:QueueContactCellDismissalTypeMeeting andMeeting:_meeting];
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
    if ([self.delegate respondsToSelector:@selector(swipeyCellDidBeginDragging:)])
        [self.delegate swipeyCellDidBeginDragging:self];
}

- (void)queueContactImageView:(QueueContactImageView *)imageView didEndDraggingWithSnooze:(BOOL)snooze
{
    if (snooze)
    {
        if ([self.delegate respondsToSelector:@selector(queueContactCell:didDismissWithType:andMeeting:)])
            [self.delegate queueContactCell:self didDismissWithType:QueueContactCellDismissalTypeSnooze andMeeting:nil];
    }
    
    [self hideSnoozeTrackWithAnimation:YES];
    if ([self.delegate respondsToSelector:@selector(swipeyCellDidEndDragging:)])
        [self.delegate swipeyCellDidEndDragging:self];
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
