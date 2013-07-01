//
//  QueueContactImageView.h
//  Queue
//
//  Created by Jeremy Lubin on 6/30/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QueueContactImageViewDelegate;

@interface QueueContactImageView : UIImageView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<QueueContactImageViewDelegate> delegate;
@property CGFloat marginLeft;

@end

@protocol QueueContactImageViewDelegate <NSObject>

- (void)queueContactImageViewDidBeginDragging:(QueueContactImageView *)imageView;
- (void)queueContactImageView:(QueueContactImageView *)imageView didEndDraggingWithSnooze:(BOOL)snooze;
- (void)queueContactImageView:(QueueContactImageView *)imageView canSnooze:(BOOL)snooze;
- (void)queueContactImageViewWillSnooze:(QueueContactImageView *)imageView;

@end