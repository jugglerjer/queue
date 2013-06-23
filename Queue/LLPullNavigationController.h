//
//  LLPullNavigationController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/15/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LLPullNavigationScrollView;

@protocol LLPullNavigationViewControllerDelegate;

@interface LLPullNavigationController : UIViewController <UIScrollViewDelegate>

@property int cellHeight;

@property (weak, nonatomic) id<LLPullNavigationViewControllerDelegate> delegate;
@property (strong, nonatomic) LLPullNavigationScrollView *scrollView;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)switchToViewController:(UIViewController *)newViewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)assumeScrollControl;
- (void)resignScrollControl;

@end

@protocol LLPullNavigationViewControllerDelegate <NSObject>

- (void)pullNavigationControllerWillEnterSelectionMode:(LLPullNavigationController *)pullNavigationController;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
              shouldSelectPage:(NSUInteger)page;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
                canSelectPage:(NSUInteger)page;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
        canNoLongerSelectPage:(NSUInteger)page;

@end
