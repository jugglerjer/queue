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
    
	// Setup the scroll view  which will
    // hold the presented subview
    LLPullNavigationScrollView *scrollView = [[LLPullNavigationScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.userInteractionEnabled = NO;
    [scrollView setDelaysContentTouches:NO];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2);
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
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
    
    self.scrollView.userInteractionEnabled = YES;
//    self.scrollView.scrollEnabled = NO;
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
