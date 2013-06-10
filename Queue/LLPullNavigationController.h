//
//  LLPullNavigationController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/15/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLPullNavigationController : UIViewController <UIScrollViewDelegate>

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)switchToViewController:(UIViewController *)newViewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)assumeScrollControl;
- (void)resignScrollControl;

@end
