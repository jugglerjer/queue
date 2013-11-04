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
@property int numberOfPages;
@property BOOL isEngaged;
@property BOOL isSwitchingToPage;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (NSUInteger)currentPage;
- (void)shouldSwitchViewControllers;
- (void)switchToViewController:(UIViewController *)newViewController atPage:(NSUInteger)page animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)adjustToPoint:(CGPoint)point;
- (void)resumeCurrentViewController:(UIViewController *)currentViewController atPage:(NSUInteger)page;
- (void)assumeScrollControl;
- (void)resignScrollControl;
- (void)enterSelectionMode;
- (void)exitSelectionMode;
- (BOOL)shouldDismissScrollView;
- (void)dismissScrollView;
- (void)presentScrollView;
- (void)engageWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)disengageWithPotentialPageSwitch:(BOOL)pageSwitch;

@end

@protocol LLPullNavigationViewControllerDelegate <NSObject>

- (void)pullNavigationControllerWillEnterSelectionMode:(LLPullNavigationController *)pullNavigationController;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
              shouldSelectPage:(NSUInteger)page;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
                canSelectPage:(NSUInteger)page;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
        canNoLongerSelectPage:(NSUInteger)page;

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
      hasIntersectedSelectedPage:(NSUInteger)page;

- (void)pullNavigationControllerHasBeenDismissed:(LLPullNavigationController *)pullNavigationViewController;

- (NSString *)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController
               nameForViewAtPage:(NSUInteger)page;

- (NSString *)pullNavigationControllerNameForShouldDismissInstruction:(LLPullNavigationController *)pullNavigationViewController;

- (NSUInteger)pullNavigationControllerNumberOfPages:(LLPullNavigationController *)pullNavigationViewController;

@end
