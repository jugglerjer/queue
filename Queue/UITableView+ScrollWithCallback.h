//
//  UITableView+ScrollWithCallback.h
//  Queue
//
//  Created by Jeremy Lubin on 10/27/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ScrollWithCallback)

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)scrollPosition
                    completion:(void (^)(void))block;

@end
