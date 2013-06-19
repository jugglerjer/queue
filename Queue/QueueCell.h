//
//  QueueCell.h
//  Queue
//
//  Created by Jeremy Lubin on 6/13/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueueCell : UITableViewCell

@property (strong, nonatomic) UILabel *queueNameLabel;
@property (strong, nonatomic) UIImageView *unselectedImageView;
@property (strong, nonatomic) UIImageView *selectedImageView;
@property (strong, nonatomic) UIImageView *selectableBackgroundView;
@property (weak, nonatomic) UITableView *queueTable;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setSelectable:(BOOL)selectable animated:(BOOL)animated;

@end
