//
//  LLPullNavigationController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/15/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLPullNavigationController.h"
#import "LLPullNavigationScrollView.h"

@interface LLPullNavigationController ()

@property (strong, nonatomic) LLPullNavigationScrollView *scrollView;
@property (strong, nonatomic) UIViewController *rootViewController;
@property (strong, nonatomic) UIViewController *currentViewController;

@end

@implementation LLPullNavigationController

static int defaultCellHeight = 44;
BOOL isScrollViewDismissed;
int currentPage = -1;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self)
    {
        // Instantiate the root view controller
        self.rootViewController = rootViewController;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the root view to the heirarchy
    [self addChildViewController:self.rootViewController];
    self.rootViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.rootViewController.view];
    [self.rootViewController didMoveToParentViewController:self];
    
	// Setup the scroll view that will
    // hold the presented subview
    CGRect frame = self.view.bounds;
    frame.origin.y = self.view.frame.size.height;
    LLPullNavigationScrollView *scrollView = [[LLPullNavigationScrollView alloc] initWithFrame:frame];
    [scrollView setDelaysContentTouches:NO];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2);
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
    
    if (!self.cellHeight)
        self.cellHeight = defaultCellHeight;
}

// -----------------------------------------
// Switch the current presented view controller
// with the newly presented view controller
// -----------------------------------------
- (void)switchToViewController:(UIViewController *)newViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (self.currentViewController)
    {
        // Remove the current presented view from the heirarchy
        [self.currentViewController willMoveToParentViewController:nil];
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
    }
    
    
    // Assign the new view to the current view property
    self.currentViewController = newViewController;
    
    [self addChildViewController:self.currentViewController];
    self.currentViewController.view.frame = self.view.bounds;
    [self.scrollView addSubview:self.currentViewController.view];
    
    [self presentScrollView:self.scrollView];
    
}

// -----------------------------------------
// Alerts the delegate when the scroll view
// is about to begin selection mode
// -----------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(pullNavigationControllerWillEnterSelectionMode:)])
        [_delegate pullNavigationControllerWillEnterSelectionMode:self];
}


// -----------------------------------------
// Recognizes when the user scrolls to a
// particular page location but before a
// selection is made
//
// &
//
// Removes the scrollView from view when the
// user scrolls it more than 50% of the way
// down the screen's view area
// -----------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Dismiss the scroll view if it's been dragged far enough
    int maxScrollDistance = self.cellHeight * 3.5;
    if (scrollView.contentOffset.y * -1 >= maxScrollDistance)
    {
        [self dismissScrollView:scrollView];
        if ([_delegate respondsToSelector:@selector(pullNavigationController:canNoLongerSelectPage:)])
            [_delegate pullNavigationController:self canNoLongerSelectPage:currentPage];
    }
    
    // Let the delegate know that we stopped hovering over the previous page
    // and began hovering over the next
    if (!isScrollViewDismissed)
    {
        double currentPosition = scrollView.contentOffset.y * -1 / self.cellHeight;
        int nextPage = floor(currentPosition) - 1 > 0 ? floor(currentPosition) - 1 : 0;
        
        if (nextPage != currentPage)
        {
            if ([_delegate respondsToSelector:@selector(pullNavigationController:canSelectPage:)])
                [_delegate pullNavigationController:self canSelectPage:nextPage];
            if ([_delegate respondsToSelector:@selector(pullNavigationController:canNoLongerSelectPage:)])
                [_delegate pullNavigationController:self canNoLongerSelectPage:currentPage];
            
        }
        currentPage = nextPage;
    }
}

// -----------------------------------------
// Dismiss the scrollView so that the user
// can select a view manually
// -----------------------------------------
- (void)dismissScrollView:(UIScrollView *)scrollView;
{
    CGRect frame = scrollView.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.25
                     animations:^{
                         scrollView.frame = frame;
                     }];
    isScrollViewDismissed = YES;
}

// -----------------------------------------
// Present the scroll view so that the user
// can interact with the presented child view
// -----------------------------------------
- (void)presentScrollView:(UIScrollView *)scrollView
{
    CGRect frame = self.scrollView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.scrollView.frame = frame;
                     }];
    isScrollViewDismissed = NO;
}

// -----------------------------------------
// Recognizes when a user stops dragging the
// scrollView over a row in the root view's
// navigation table and initiates a call to
// the delegate to change the view
// -----------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!isScrollViewDismissed)
    {
        int page = abs(scrollView.contentOffset.y) / self.cellHeight;
        if ([_delegate respondsToSelector:@selector(pullNavigationController:shouldSelectPage:)])
            [_delegate pullNavigationController:self shouldSelectPage:page];
    }
}

// -----------------------------------------
// Switch touch handling from the child view
// controller to the pull nav controller
// so that we can iniate the pulldown mechanism
// -----------------------------------------
- (void)assumeScrollControl
{
    [self.scrollView becomeFirstResponder];
    self.scrollView.scrollEnabled = YES;
}

// -----------------------------------------
// Switch touch handling from the pull nav
// controller to the child controller
// so that the child behaves normally
// -----------------------------------------
- (void)resignScrollControl
{
//    self.scrollView.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
