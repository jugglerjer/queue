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
        [self addSubview:contactImage];
        
        // Contact Name
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, 26.0f, 160.0f, 22.0f)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        nameLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel = nameLabel;
        [self addSubview:self.nameLabel];
        
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
        
        self.dueDateLabel = dueDateLabel;
        self.unitsLabel = unitsLabel;
        self.statusLabel = statusLabel;
        self.dueLabel = dueLabel;
        
        [self addSubview:self.dueDateLabel];
        [self addSubview:self.unitsLabel];
        [self addSubview:self.statusLabel];
        [self addSubview:self.dueLabel];
        
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
