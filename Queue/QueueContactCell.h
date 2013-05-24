//
//  QueueContactCell.h
//  Queue
//
//  Created by Jeremy Lubin on 5/23/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;

@interface QueueContactCell : UITableViewCell

@property (strong, nonatomic) UIImageView *contactImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dueDateLabel;
@property (strong, nonatomic) UILabel *unitsLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *dueLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithContact:(Contact *)contact;

@end
