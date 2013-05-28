//
//  MeetingCell.h
//  Queue
//
//  Created by Jeremy Lubin on 5/26/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Meeting;

@interface MeetingCell : UITableViewCell

@property (strong, nonatomic) UILabel *noteLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) UIView *topLine;
@property (strong, nonatomic) UIView *bottomLine;
@property (strong, nonatomic) UIView *tableTopLine;
@property (strong, nonatomic) UIView *tableBottomLine;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithMeeting:(Meeting *)meeting;

@end
