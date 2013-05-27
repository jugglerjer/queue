//
//  MeetingCell.m
//  Queue
//
//  Created by Jeremy Lubin on 5/26/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "MeetingCell.h"
#import "Meeting.h"

#define MARGIN_TOP      20
#define MARGIN_BOTTOM   20
#define MARGIN_LEFT     63
#define MARGIN_RIGHT    30

#define NOTE_HEIGHT     20
#define DATE_HEIGHT     18

@implementation MeetingCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIView *background = [[UIView alloc] initWithFrame:self.frame];
        background.backgroundColor = [UIColor whiteColor];
        self.backgroundView = background;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT,
                                                                       MARGIN_TOP,
                                                                       self.bounds.size.width - MARGIN_LEFT - MARGIN_RIGHT,
                                                                       DATE_HEIGHT)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        dateLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = dateLabel;
        [self addSubview:self.dateLabel];
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT,
                                                                       MARGIN_TOP + DATE_HEIGHT,
                                                                       self.bounds.size.width - MARGIN_LEFT - MARGIN_RIGHT,
                                                                       NOTE_HEIGHT)];
        noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        noteLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.numberOfLines = 0;
        self.noteLabel = noteLabel;
        [self addSubview:self.noteLabel];
        
        CGRect lineFrame = CGRectMake(0,0,self.bounds.size.width, 0.5);

        UIView *topLine = [[UIView alloc] initWithFrame:lineFrame];
        topLine.backgroundColor = [UIColor whiteColor];
        topLine.alpha = 0.2;
        self.topLine = topLine;
        [self addSubview:self.topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor blackColor];
        bottomLine.alpha = 0.1;
        self.bottomLine = bottomLine;
        [self addSubview:self.bottomLine];
        
        UIView *tableTopLine = [[UIView alloc] initWithFrame:lineFrame];
        topLine.backgroundColor = [UIColor blackColor];
        topLine.alpha = 0.1;
        self.tableTopLine = tableTopLine;
        [self addSubview:self.topLine];
        
        UIView *tableBottomLine = [[UIView alloc] initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor whiteColor];
        bottomLine.alpha = 0.2;
        self.tableBottomLine = tableBottomLine;
        [self addSubview:self.bottomLine];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)configureWithMeeting:(Meeting *)meeting
{
    self.noteLabel.text = meeting.note;
    [self.noteLabel sizeToFit];
    
    NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
    [meetingDateFormatter setDateFormat:@"MMMM d, y"];
    self.dateLabel.text = [meetingDateFormatter stringFromDate:meeting.date];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
