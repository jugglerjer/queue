//
//  QueueBarButtonItem.m
//  Queue
//
//  Created by Jeremy Lubin on 5/22/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueBarButtonItem.h"

@implementation QueueBarButtonItem

- (id)initWithType:(QueueBarButtonItemType)type target:(id)target action:(SEL)action
{
    if (self = [super init])
    {
        self.target = target;
        self.action = action;
        
        // Set the button's image
        NSString *normalImageName;
        
        switch (type) {
            case QueueBarButtonItemTypeAdd:
                normalImageName = @"add.png";
                break; 
                
            case QueueBarButtonItemTypeDone:
                normalImageName = @"done.png";
                break;
                
            case QueueBarButtonItemTypeCancel:
                normalImageName = @"cancel.png";
                break;
                
            case QueueBarButtonItemTypeBack:
                normalImageName = @"back.png";
                break;
                
            case QueueBarButtonItemTypeList:
                normalImageName = @"list-flat.png";
                break;
                
            default:
                break;
        }
        
        UIImage *normalImage = [UIImage imageNamed:normalImageName];
        
        // Create the button
        CGFloat buttonMargin = 0.0f;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonMargin, 0, normalImage.size.width + (2*buttonMargin), normalImage.size.height + (2*buttonMargin));
        button.contentMode = UIViewContentModeCenter;
        [button setImage:normalImage forState:UIControlStateNormal];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:normalImage];
//        [button addSubview:imageView];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//        button.showsTouchWhenHighlighted = YES;
//        button.autoresizingMask = UIViewAutoresizingNone;
        button.imageView.autoresizingMask = UIViewAutoresizingNone;
        button.imageView.contentMode = UIViewContentModeCenter;
        button.imageView.clipsToBounds = NO;
        button.autoresizesSubviews = NO;
//        button.imageView.backgroundColor = [UIColor greenColor];
//        button.backgroundColor = [UIColor orangeColor];
        
        [self setCustomView:button];
    }
    
    return self;
}

@end
