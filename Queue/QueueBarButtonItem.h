//
//  QueueBarButtonItem.h
//  Queue
//
//  Created by Jeremy Lubin on 5/22/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    QueueBarButtonItemTypeAdd,
    QueueBarButtonItemTypeDone,
    QueueBarButtonItemTypeCancel,
    QueueBarButtonItemTypeBack,
    QueueBarButtonItemTypeMenu
} QueueBarButtonItemType;

@interface QueueBarButtonItem : UIBarButtonItem

- (id)initWithType:(QueueBarButtonItemType)type target:(id)target action:(SEL)action;

@end
