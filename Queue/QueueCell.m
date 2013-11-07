//
//  QueueCell.m
//  Queue
//
//  Created by Jeremy Lubin on 6/13/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueCell.h"
#import <QuartzCore/QuartzCore.h>

#define NAME_LABEL_MARGIN_RIGHT     21
#define NAME_LABEL_MARGIN_LEFT      19
#define NAME_LABEL_MARGIN_TOP       10
#define NAME_LABEL_MARGIN_BOTTOM    9

#define DELETE_LABEL_MARGIN_RIGHT     21
#define DELETE_LABEL_MARGIN_LEFT      30
#define DELETE_LABEL_MARGIN_TOP       10
#define DELETE_LABEL_MARGIN_BOTTOM    9

#define DELETE_BUTTON_MARGIN_RIGHT  21
#define DELETE_BUTTON_WIDTH         44
#define DELETE_BUTTON_HEIGHT        44

@interface QueueCell ()

@property (strong, nonatomic) NSString *originalQueueName;
@property (strong, nonatomic) UIColor *activeColor;
@property (strong, nonatomic) UIColor *inactiveColor;

@end

@implementation QueueCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithDetailType:LLSwipeyCellDetailTypeAdjacent reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
        self.underView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:88.0/255.0 blue:92.0/255.0 alpha:1];
        self.swipeyView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
        
        self.activeColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.inactiveColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1.0];
        
        // Create the selectable background view
        UIImageView *selectableBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue-cell-background-selectable.png"]];
        selectableBackgroundView.alpha = 0;
        self.selectableBackgroundView = selectableBackgroundView;
        [self.swipeyView addSubview:self.selectableBackgroundView];
        
        // Set up queue name label
        CGRect nameFrame = CGRectMake(self.bounds.origin.x + NAME_LABEL_MARGIN_LEFT,
                                      self.bounds.origin.y + NAME_LABEL_MARGIN_TOP,
                                      self.frame.size.width - (NAME_LABEL_MARGIN_LEFT + NAME_LABEL_MARGIN_RIGHT),
                                      self.frame.size.height - (NAME_LABEL_MARGIN_TOP + NAME_LABEL_MARGIN_BOTTOM));
        UITextField *queueNameLabel = [[UITextField alloc] initWithFrame:nameFrame];
        queueNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        queueNameLabel.textAlignment = NSTextAlignmentCenter;
        queueNameLabel.backgroundColor = [UIColor clearColor];
        queueNameLabel.delegate = self;
        queueNameLabel.placeholder = @"New Queue";
        //        queueNameLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
        //        queueNameLabel.shadowOffset = CGSizeMake(0, -1);
        //        queueNameLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
        queueNameLabel.layer.shadowOpacity = 1.0;
        queueNameLabel.layer.shadowRadius = 1.0;
        queueNameLabel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
        queueNameLabel.layer.shadowOffset = CGSizeMake(0.0, -1.0);
//        queueNameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.2];
        [queueNameLabel setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        [queueNameLabel addTarget:self action:@selector(nameTextFieldDidChange:) forControlEvents:UIControlEventAllEditingEvents];
        queueNameLabel.userInteractionEnabled = NO;
        self.queueNameLabel = queueNameLabel;
        
        // Set up queue name label
        CGRect deleteFrame = CGRectMake(self.bounds.origin.x + DELETE_LABEL_MARGIN_LEFT,
                                      self.bounds.origin.y + DELETE_LABEL_MARGIN_TOP,
                                      self.frame.size.width - (DELETE_LABEL_MARGIN_LEFT + DELETE_LABEL_MARGIN_RIGHT),
                                      self.frame.size.height - (DELETE_LABEL_MARGIN_TOP + DELETE_LABEL_MARGIN_BOTTOM));
        _deleteLabel = [[UILabel alloc] initWithFrame:deleteFrame];
        _deleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        _deleteLabel.textColor = [UIColor whiteColor];
        _deleteLabel.textAlignment = NSTextAlignmentLeft;
        _deleteLabel.backgroundColor = [UIColor clearColor];
        _deleteLabel.text = @"Swipe to delete";
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(self.frame.size.width - DELETE_BUTTON_MARGIN_RIGHT - DELETE_BUTTON_WIDTH, 0.0, DELETE_BUTTON_WIDTH, DELETE_BUTTON_HEIGHT);
        [deleteButton setImage:[UIImage imageNamed:@"confirm-delete-queue.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteQueue:) forControlEvents:UIControlEventTouchUpInside];
        [self.underView addSubview:deleteButton];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        
        [self.swipeyView addSubview:self.queueNameLabel];
        [self.swipeyView addGestureRecognizer:longPress];
        [self.underView addSubview:_deleteLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.dragThreshold = self.frame.size.width * .75;
    }
    return self;
}

// -----------------------------------------
// Handle queue deletion
// -----------------------------------------
- (void)deleteQueue:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(queueCellDidDeleteQueue:)])
        [self.delegate queueCellDidDeleteQueue:self];
}

// -----------------------------------------
// When the user does a long press on the cell
// begin editing the queue name
// -----------------------------------------
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    self.queueNameLabel.userInteractionEnabled = YES;
    [self.queueNameLabel becomeFirstResponder];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

// -----------------------------------------
// Store original queue name in case we
// need to revert to it when editing is done
// -----------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.originalQueueName = textField.text;
}

// -----------------------------------------
// Turn off user interaction for the queue
// name field when editing is done. Only
// re-enable this with a long tap on the cell.
//
// Also update the name of the queue
// -----------------------------------------
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.userInteractionEnabled = NO;
    
    // Update the name of the queue, unless the new name is blank
    // in which case revert to the old name
    if (![self.queueNameLabel.text isEqualToString:@""]) {
        if ([self.delegate respondsToSelector:@selector(queueCell:didEndNameEditingWithNewName:)])
            [self.delegate queueCell:self didEndNameEditingWithNewName:self.queueNameLabel.text];
    }
    else {
        self.queueNameLabel.text = self.originalQueueName;
    }
}

- (void)nameTextFieldDidChange:(UITextField *)nameTextField
{
//    [self setQueueNameLabelFont];
}

- (void)setSelectable:(BOOL)selectable animated:(BOOL)animated
{
    double alpha;
    if (selectable)
        alpha = 1.0;
    else
        alpha = 0.0;
    
    double duration;
    double delay;
    if (animated)
    {
        duration = 0.1;
        delay = selectable ? duration + 0.1 : 0.0;
    }
    else
    {
        duration = 0.0;
        delay = 0.0;
    }
    
    if (selectable)
        [self.queueTable bringSubviewToFront:self];
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.selectableBackgroundView.alpha = alpha;
                         self.queueNameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:alpha];
                     }
                     completion:^(BOOL finished){
                         if (!selectable)
                             [self.queueTable sendSubviewToBack:self];
                     }
     ];
    
    [self setActive:selectable animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActive:(BOOL)active animated:(BOOL)animated
{
    UIColor *color = active ? self.activeColor : self.activeColor;
    CGFloat alpha = active ? 1.0 : 0.2;
//    CGSize size = active ? CGSizeMake(0.0, -1.0) : CGSizeMake(0.0, 1.0);
    CGFloat duration = animated ? 0.1 : 0.0;
    
    [UIView transitionWithView:self.queueNameLabel
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.queueNameLabel setTextColor:color];
                        [self.queueNameLabel setAlpha:alpha];
//                        self.queueNameLabel.layer.shadowOffset = size;
                    }
                    completion:nil];
}

@end
