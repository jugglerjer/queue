//
//  UITableView+ScrollWithCallback.m
//  Queue
//
//  Created by Jeremy Lubin on 10/27/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "UITableView+ScrollWithCallback.h"

@implementation UITableView (ScrollWithCallback)

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)scrollPosition
                    completion:(void (^)(void))block
{
    // Create the table view's new bounds
    CGRect newBounds = self.bounds;
    
    // Set maximum and minimum offsets so that the table isn't
    // scrolled to an unnatural position
    
    
    // Set the new bounds value according to the scroll position
//    CGFloat offsetY;
//    switch (scrollPosition) {
//            
//        // Top
//        // Scroll the table so that row at indexPath is at the top
//        case UITableViewScrollPositionTop:
//            offsetY = self.rowHeight * 
//            break;
//            
//        case UITableViewScrollPositionMiddle:
//            <#statements#>
//            break;
//            
//        case UITableViewScrollPositionBottom:
//            <#statements#>
//            break;
//            
//        case UITableViewScrollPositionNone:
//            <#statements#>
//            break;
//            
//        default:
//            break;
//    }
}

@end
