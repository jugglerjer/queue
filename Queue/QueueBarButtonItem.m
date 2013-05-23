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
                
            default:
                break;
        }
        
        UIImage *normalImage = [UIImage imageNamed:normalImageName];
        
        // Create the button
        CGFloat buttonMargin = 10.0f;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonMargin, 0, normalImage.size.width + (2*buttonMargin), normalImage.size.height);
        button.contentMode = UIViewContentModeCenter;
        [button setImage:normalImage forState:UIControlStateNormal];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        button.showsTouchWhenHighlighted = YES;
        
        [self setCustomView:button];
    }
    
    return self;
}

@end
