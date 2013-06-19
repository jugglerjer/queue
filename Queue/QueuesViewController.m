//
//  QueuesViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueuesViewController.h"
#import "QueueViewController.h"
#import "QueueCell.h"
#import "QueueBarButtonItem.h"
#import "Queue.h"

@interface QueuesViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *queuesArray;
@property (weak, nonatomic) QueueViewController *queueViewController;

@end

@implementation QueuesViewController

int selectedQueue;

# pragma mark - Queue Management Methods

// -------------------------------------------------------------
// Create a new Queue
// -------------------------------------------------------------
- (void)addQueue
{
    // Create a new Queue managed object
    Queue *newQueue = (Queue *)[NSEntityDescription insertNewObjectForEntityForName:@"Queue"
                                                                   inManagedObjectContext:_managedObjectContext];
    newQueue.name = @"Queue";
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    } else {
        [self.queuesArray addObject:newQueue];
    }
    [_tableView reloadData];
}

# pragma mark - Queue Display Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queuesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *QueueRowIdentifier = @"QueueRowIdentifier";
    QueueCell *cell = [tableView dequeueReusableCellWithIdentifier:QueueRowIdentifier];
    if (cell == nil) {
        cell = [[QueueCell alloc] initWithReuseIdentifier:QueueRowIdentifier];
    }
    Queue *queue = (Queue *)[self.queuesArray objectAtIndex:indexPath.row];
    cell.queueNameLabel.text = queue.name;
    cell.queueTable = self.tableView;
    CGRect frame = cell.selectableBackgroundView.frame;
    frame.origin.y = -5;
    cell.selectableBackgroundView.frame = frame;
    return cell;
}

# pragma mark - Queue Row Selection Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self switchToQueueAtIndex:indexPath.row];
}

- (void)pullNavigationControllerWillEnterSelectionMode:(LLPullNavigationController *)pullNavigationController
{
//    [self.queueViewController.navigationController setNavigationBarHidden:YES];
//    CGRect frame = self.queueViewController.view.frame;
//    frame.origin.y = frame.origin.y + self.queueViewController.navigationController.navigationBar.frame.size.height;
//    self.queueViewController.view.frame = frame;
    
    self.queueViewController.navigationController.navigationBar.alpha = 0;
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController shouldSelectPage:(NSUInteger)page
{
    if (page != selectedQueue)
        [self switchToQueueAtIndex:page];
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController canSelectPage:(NSUInteger)page
{
//    [self.queueViewController.navigationController setNavigationBarHidden:YES animated:NO];
    QueueCell *cell = (QueueCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    [cell setSelectable:YES animated:YES];
    [self.tableView performSelector:@selector(bringSubviewToFront:) withObject:cell afterDelay:0.4];
//    [self.tableView bringSubviewToFront:cell];
    NSLog(@"%d", page);
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController canNoLongerSelectPage:(NSUInteger)page
{
    QueueCell *cell = (QueueCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    [cell setSelectable:NO animated:YES];
    [self.tableView performSelector:@selector(sendSubviewToBack:) withObject:cell afterDelay:0.4];
//    [self.tableView sendSubviewToBack:cell];
    NSLog(@"%d", page);
}

- (void)switchToQueueAtIndex:(NSInteger)index
{
    // If the selected queue doesn't exist, choose the queue at the highest index allowed instead
    if (index >= [self.queuesArray count])
    {
        index = [self.queuesArray count] - 1;
    }
    
    QueueViewController *queueView = [[QueueViewController alloc] initWithQueue:[self.queuesArray objectAtIndex:index]];
    queueView.managedObjectContext = self.managedObjectContext;
    queueView.title = [[self.queuesArray objectAtIndex:index] name];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:queueView];
//    [queueView.navigationController setNavigationBarHidden:NO animated:NO];
    LLPullNavigationController *pullController = (LLPullNavigationController *)self.parentViewController;
    [pullController switchToViewController:navController animated:YES completion:nil];
    
    self.queueViewController = queueView;
    selectedQueue = index;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

# pragma mark - View Management Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LLPullNavigationController *pullController = (LLPullNavigationController *)self.parentViewController;
    pullController.delegate = self;
	
    // Create a table view to hold the contacts
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    for (UIGestureRecognizer *gesture in self.tableView.gestureRecognizers)
    {
        if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]])
        {
            gesture.delegate = self;
        }
        
    }
    
    // Add the add contact button to the right side of the nav bar
    QueueBarButtonItem *addContactButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeAdd target:self action:@selector(addQueue)];
    self.navigationItem.rightBarButtonItem = addContactButton;
    
    // Load all of the Queues from memory
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Queue" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    # pragma mark - TODO sort the queues

    [self setQueuesArray:mutableFetchResults];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
