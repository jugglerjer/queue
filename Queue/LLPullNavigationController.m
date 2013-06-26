//
//  LLPullNavigationController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/15/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLPullNavigationController.h"
#import "LLPullNavigationScrollView.h"
#import <QuartzCore/QuartzCore.h>

#define INSTRUCTION_MARGIN_TOP          50
#define INSTRUCTION_MARGIN_LEFT         20
//#DEFINE INSTRUCTION_MARGIN_BOTTOM       50
#define INSTRUCTION_MARGIN_RIGHT        20
#define INSTRUCTION_HEIGHT              60

#define ARROW_MARGIN_TOP                20

@interface LLPullNavigationController ()
@property (strong, nonatomic) UIViewController *rootViewController;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic) UIView *instructionView;
@property (strong, nonatomic) UIImageView *pullArrow;
@property (strong, nonatomic) UILabel *instructionLabel;

@end

@implementation LLPullNavigationController

static int defaultCellHeight = 44;
BOOL isScrollViewDismissed;
BOOL isInSelectionMode;
BOOL isSwitchingToPage;
int currentPage = -1;
int pageToSwitchTo;
#define degreesToRadians(x) (M_PI * x / 180.0)

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
//    frame.origin.y = self.view.frame.size.height;
    LLPullNavigationScrollView *scrollView = [[LLPullNavigationScrollView alloc] initWithFrame:frame];
    [scrollView setDelaysContentTouches:NO];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2.0);
    scrollView.delegate = self;
    scrollView.scrollEnabled = NO;
    scrollView.userInteractionEnabled = NO;
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
//    [self.scrollView setContentOffset:CGPointMake(0, self.view.frame.size.height)];
    isScrollViewDismissed = YES;
    
    // Setup the instruction view that will
    // cover the child view controller when
    // in view switching mode
    UIView *instructionView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                       self.view.bounds.origin.y + self.view.frame.size.height + 44.0,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height - 44.0)];
    instructionView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
    instructionView.alpha = 0.0;
    instructionView.userInteractionEnabled = NO;
    self.instructionView = instructionView;
    
    UIImageView *pullArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull-to-switch-arrow.png"]];
    pullArrow.frame = CGRectMake((instructionView.frame.size.width - pullArrow.frame.size.width) / 2.0,
                                 ARROW_MARGIN_TOP, pullArrow.frame.size.width, pullArrow.frame.size.height);
    self.pullArrow = pullArrow;
    [self.instructionView addSubview:self.pullArrow];
    
    // Add an instruction label to the view
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(instructionView.bounds.origin.x + INSTRUCTION_MARGIN_LEFT,
                                                                          instructionView.bounds.origin.y + INSTRUCTION_MARGIN_TOP,
                                                                          instructionView.frame.size.width - INSTRUCTION_MARGIN_LEFT - INSTRUCTION_MARGIN_RIGHT,
                                                                          INSTRUCTION_HEIGHT)];
    instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    instructionLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.backgroundColor = [UIColor clearColor];
    instructionLabel.numberOfLines = 0;
    self.instructionLabel = instructionLabel;
    [self.instructionView addSubview:self.instructionLabel];
    [self.scrollView addSubview:self.instructionView];
    
    if (!self.cellHeight)
        self.cellHeight = defaultCellHeight;
}

// -----------------------------------------
// Report the currently selectable page
// -----------------------------------------
- (NSUInteger)currentPage
{
    return currentPage;
}

// -----------------------------------------
// Switch the current presented view controller
// with the newly presented view controller
// -----------------------------------------
- (void)switchToViewController:(UIViewController *)newViewController atPage:(NSUInteger)page animated:(BOOL)animated completion:(void (^)(void))completion
{
    pageToSwitchTo = page;
    
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
    CGRect frame = self.view.bounds;
    frame.origin.y = self.view.frame.size.height;
    self.currentViewController.view.frame = frame;
    [self.scrollView addSubview:self.currentViewController.view];
    
    [self.scrollView bringSubviewToFront:self.instructionView];
    [self presentScrollView];
    
    NSLog(@"Switching page");
    
}

// -----------------------------------------
// Reinstate the current view controller
// -----------------------------------------
- (void)resumeCurrentViewController:(UIViewController *)currentViewController atPage:(NSUInteger)page
{
    pageToSwitchTo = page;
    [self setPageSwitchingMode:YES withDelay:0.0];
    [self setPageSwitchingMode:NO withDelay:0.4];
}

// -----------------------------------------
// Enter Selection Mode
// -----------------------------------------
- (void)enterSelectionMode
{
    isInSelectionMode = YES;
    NSLog(@"Enter selection mode");
}

// -----------------------------------------
// Exit Selection Mode
// -----------------------------------------
- (void)exitSelectionMode
{
    isInSelectionMode = NO;
    NSLog(@"Exit selection mode");
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
//   NSLog(@"%f", scrollView.contentOffset.y);
    // Let the delegate know that we stopped hovering over the previous page
    // and began hovering over the next
    if (isInSelectionMode)
    {
        // Dismiss the scroll view if it's been dragged far enough
//        float minOffset = scrollView.frame.size.height - (self.cellHeight * 3.0);
//        if (ABS(scrollView.contentOffset.y) <= minOffset)
//        {
//            [self exitSelectionMode];
//            [self dismissScrollView];
//
//        }
        
        if ([self shouldDismissScrollView])
        {
            if ([_delegate respondsToSelector:@selector(pullNavigationController:canNoLongerSelectPage:)])
                [_delegate pullNavigationController:self canNoLongerSelectPage:currentPage];
        }
        
        double currentPosition = ABS(scrollView.contentOffset.y - scrollView.frame.size.height) / self.cellHeight;
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
    
    // If we're just starting to scroll, slowly fade in the instruction view
    [self updateInstructionView];
    
    // If we're switching to a page, notify the delegate when we reach the beginning of the page
    if (isSwitchingToPage)
    {
        double currentPosition = ABS(scrollView.contentOffset.y - scrollView.frame.size.height);
        double pagePosition = (self.cellHeight * pageToSwitchTo);
        if (currentPosition <= pagePosition)
        {
            if ([_delegate respondsToSelector:@selector(pullNavigationController:hasIntersectedSelectedPage:)])
                [_delegate pullNavigationController:self hasIntersectedSelectedPage:pageToSwitchTo];
        }
    }
}

// -----------------------------------------
// Reports whether or not the controller
// should dismiss its scroll view.
// Useful so that the child view knows
// whether or not to select a page when the
// user stops dragging.
// -----------------------------------------
- (BOOL)shouldDismissScrollView
{
    // Dismiss the scroll view if it's been dragged far enough
    float minOffset = self.scrollView.frame.size.height - (self.cellHeight * 3.0);
    if (ABS(self.scrollView.contentOffset.y) <= minOffset)
        return YES;
    
    return NO;
}

// -----------------------------------------
// Dismiss the scrollView so that the user
// can select a view manually
// -----------------------------------------
- (void)dismissScrollView
{
//    CGRect frame = scrollView.frame;
//    frame.origin.y = self.view.frame.size.height;
//    [UIView animateWithDuration:0.25
//                     animations:^{
//                         scrollView.frame = frame;
//                     }];
//    isScrollViewDismissed = YES;
    self.scrollView.userInteractionEnabled = NO;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

// -----------------------------------------
// Present the scroll view so that the user
// can interact with the presented child view
// -----------------------------------------
- (void)presentScrollView
{
//    CGRect frame = self.scrollView.frame;
//    frame.origin.y = 0;
//    [UIView animateWithDuration:0.25
//                     animations:^{
//                         self.scrollView.frame = frame;
//                     }];
    self.scrollView.userInteractionEnabled = YES;
    [self setPageSwitchingMode:YES withDelay:0.0];
    [self.scrollView setContentOffset:CGPointMake(0, self.view.frame.size.height) animated:YES];
    [self setPageSwitchingMode:NO withDelay:0.4];
    
}

// -----------------------------------------
// Switch off the page switching mode
// after a delay
// -----------------------------------------
- (void)setPageSwitchingMode:(BOOL)mode withDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(setPageSwitchingMode:) withObject:[NSNumber numberWithBool:mode] afterDelay:delay];
}

- (void)setPageSwitchingMode:(NSNumber *)mode
{
    isSwitchingToPage = [mode boolValue];
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
        int page = ABS(scrollView.contentOffset.y) / self.cellHeight;
        if ([_delegate respondsToSelector:@selector(pullNavigationController:shouldSelectPage:)])
            [_delegate pullNavigationController:self shouldSelectPage:page];
    }
}

// -----------------------------------------
// Responds to message from a child view
// when it's time to switch view controllers
// -----------------------------------------
- (void)shouldSwitchViewControllers
{
    if ([_delegate respondsToSelector:@selector(pullNavigationController:shouldSelectPage:)])
        [_delegate pullNavigationController:self shouldSelectPage:currentPage];
}

// -----------------------------------------
// Update the instruction view's opacity
// to correspond with how much the child
// view has been scrolled
// -----------------------------------------
- (void)updateInstructionView
{
//    if (!isSwitchingToPage)
//    {
        float scrollDistance = ABS(self.scrollView.contentOffset.y - self.scrollView.frame.size.height);
        float alpha = scrollDistance/self.cellHeight <= 1.0 ? scrollDistance/self.cellHeight : 1.0;
        self.instructionView.alpha = alpha;
//    }
//    NSLog(@"%f", alpha);
    
    [self updateInstructionLabel];
    [self updateInstructionArrow];
}

// -----------------------------------------
// Update the instruction text to correspond
// to the currently selectable view
// -----------------------------------------
- (void)updateInstructionLabel
{
    
    NSString *labelText;
    if ([self shouldDismissScrollView])
    {
        if ([_delegate respondsToSelector:@selector(pullNavigationControllerNameForShouldDismissInstruction:)])
            labelText = [_delegate pullNavigationControllerNameForShouldDismissInstruction:self];
        else
            labelText = @"Release to see all views";
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(pullNavigationController:nameForViewAtPage:)])
            labelText = [_delegate pullNavigationController:self nameForViewAtPage:currentPage];
        else
            labelText = @"Release to switch views";
    }
    
    self.instructionLabel.text = labelText;
}

// -----------------------------------------
// Update the instruction arrow to face the
// correct direction (either to pull or release)
// -----------------------------------------
- (void)updateInstructionArrow
{
    CGAffineTransform transform;
//    int numberOfPages;
//    if ([_delegate respondsToSelector:@selector(pullNavigationControllerNumberOfPages:)])
//        numberOfPages = [_delegate pullNavigationControllerNumberOfPages:self];
    
    if (currentPage == 0 || [self shouldDismissScrollView])
        transform = CGAffineTransformMakeRotation(degreesToRadians(0));
    else
        transform = CGAffineTransformMakeRotation(degreesToRadians(180));
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.pullArrow.transform = transform;
                     }];
}

// -----------------------------------------
// Switch touch handling from the child view
// controller to the pull nav controller
// so that we can iniate the pulldown mechanism
// -----------------------------------------
- (void)assumeScrollControl
{
//    [self.scrollView becomeFirstResponder];
//    self.scrollView.scrollEnabled = YES;
    self.isEngaged = YES;
}

// -----------------------------------------
// Switch touch handling from the pull nav
// controller to the child controller
// so that the child behaves normally
// -----------------------------------------
- (void)resignScrollControl
{
//    self.scrollView.userInteractionEnabled = NO;
    self.isEngaged = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
