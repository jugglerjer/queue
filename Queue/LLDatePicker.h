//
//  LLCalendarViewController.h
//  CalendarViewDemo
//
//  Created by Jeremy Lubin on 9/9/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLDatePicker : UIControl <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSDate *date;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;

- (void)hideWithAnimation:(BOOL)animated;
- (void)hideWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay;
- (void)hideWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(void (^)())completionBlock;
- (void)showWithAnimation:(BOOL)animated;
- (void)showWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay;
- (void)showWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(void (^)())completionBlock;

@end
