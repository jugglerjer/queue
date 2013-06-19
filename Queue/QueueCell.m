//
//  QueueCell.m
//  Queue
//
//  Created by Jeremy Lubin on 6/13/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueCell.h"

#define NAME_LABEL_MARGIN_RIGHT     20
#define NAME_LABEL_MARGIN_LEFT      20
#define NAME_LABEL_MARGIN_TOP       12
#define NAME_LABEL_MARGIN_BOTTOM    12

@implementation QueueCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
        self.contentView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
        
        // Create the selectable background view
        UIImageView *selectableBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue-cell-background-selectable.png"]];
        selectableBackgroundView.alpha = 0;
        self.selectableBackgroundView = selectableBackgroundView;
        [self addSubview:self.selectableBackgroundView];
        
        // Set up queue name label
        CGRect nameFrame = CGRectMake(self.bounds.origin.x + NAME_LABEL_MARGIN_LEFT,
                                      self.bounds.origin.y + NAME_LABEL_MARGIN_TOP,
                                      self.frame.size.width - (NAME_LABEL_MARGIN_LEFT + NAME_LABEL_MARGIN_RIGHT),
                                      self.frame.size.height - (NAME_LABEL_MARGIN_TOP + NAME_LABEL_MARGIN_BOTTOM));
        UILabel *queueNameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        queueNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        queueNameLabel.textAlignment = NSTextAlignmentCenter;
        queueNameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        queueNameLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
        queueNameLabel.shadowOffset = CGSizeMake(0, -1);
        queueNameLabel.backgroundColor = [UIColor clearColor];
        self.queueNameLabel = queueNameLabel;
        [self addSubview:self.queueNameLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
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
                     }
                     completion:^(BOOL finished){
                         if (!selectable)
                             [self.queueTable sendSubviewToBack:self];
                     }
     ];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
