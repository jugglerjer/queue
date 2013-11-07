//
//  QueuesViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueuesViewController.h"
#import "QueueViewController.h"
#import "QueueBarButtonItem.h"
#import "Queue.h"
#import <QuartzCore/QuartzCore.h>

#define NAME_LABEL_MARGIN_RIGHT     21
#define NAME_LABEL_MARGIN_LEFT      19
#define NAME_LABEL_MARGIN_TOP       10
#define NAME_LABEL_MARGIN_BOTTOM    9

@interface QueuesViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *queueNameTextField;
@property (nonatomic) NSMutableArray *queuesArray;
@property (strong, nonatomic) NSMutableArray *queueViewControllersArray;
@property (weak, nonatomic) QueueViewController *queueViewController;
@property (strong, nonatomic) QueueCell *cellForDeletion;

@end

@implementation QueuesViewController

int selectedQueue;
CGFloat rowHeight = 44.0;

# pragma mark - Queue Management Methods

// -------------------------------------------------------------
// Save any new data to the data store
// -------------------------------------------------------------
- (BOOL)saveQueueData
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        return NO;
    } else {
        return YES;
    }
}

// -------------------------------------------------------------
// Create a new Queue
// -------------------------------------------------------------
- (void)addQueueWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""])
        name = @"Queue";
    
    // Create a new Queue managed object
    Queue *newQueue = (Queue *)[NSEntityDescription insertNewObjectForEntityForName:@"Queue"
                                                                   inManagedObjectContext:_managedObjectContext];
    newQueue.name = name;
    if ([self saveQueueData])
    {
        [self.queuesArray insertObject:newQueue atIndex:0];
        [self.queueViewControllersArray insertObject:[NSNull null] atIndex:0];
    }
//        [self.queuesArray addObject:newQueue];
    
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
    cell.delegate = self;
    cell.showsReorderControl = YES;
//    [cell.editingAccessoryView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reorder-control.png"]]];
    CGRect frame = cell.selectableBackgroundView.frame;
    frame.origin.y = -5;
    cell.selectableBackgroundView.frame = frame;
    [cell setActive:YES animated:NO];
    return cell;
}

// -----------------------------------------
// Change all the cells to either a normal
// text color or a de-emphasized text color
// -----------------------------------------
- (void)updateAllCellsWithEmphasis:(BOOL)emphasis animated:(BOOL)animated
{
    for (int i = 0; i < [self.queuesArray count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        QueueCell *cell = (QueueCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell setActive:emphasis animated:animated];
    }
}

# pragma mark - Queue Row Selection Methods

- (void)setNavigationBar:(UINavigationBar *)navBar alpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         navBar.alpha = alpha;
                     }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueueCell *cell = (QueueCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isEqual:_cellForDeletion])
        return nil;
    
    if (_cellForDeletion)
        [_cellForDeletion resetCellWithAnimation:YES];
    
    return indexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self switchToQueueAtIndex:indexPath.row];
//    QueueViewController *queueView = [[QueueViewController alloc] initWithQueue:[self.queuesArray objectAtIndex:indexPath.row]];
//    queueView.managedObjectContext = self.managedObjectContext;
//    queueView.title = [[self.queuesArray objectAtIndex:indexPath.row] name];
//    
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:queueView];
//    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (NSUInteger)pullNavigationControllerNumberOfPages:(LLPullNavigationController *)pullNavigationViewController
{
    return [self.queuesArray count];
}

- (void)pullNavigationControllerWillEnterSelectionMode:(LLPullNavigationController *)pullNavigationController
{    
//    self.queueViewController.navigationController.navigationBar.alpha = 0;
//    [self setNavigationBar:self.queueViewController.navigationController.navigationBar alpha:0.0 withDuration:0.0];
//    [self.tableView setEditing:YES animated:NO];
    [self updateAllCellsWithEmphasis:NO animated:NO];
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController shouldSelectPage:(NSUInteger)page
{
    if (page != selectedQueue)
    {
        [self switchToQueueAtIndex:page];
        [self.tableView setEditing:NO animated:NO];
    }
    else
    {
        [pullNavigationViewController resumeCurrentViewController:self.queueViewController atPage:page];
    }
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController canSelectPage:(NSUInteger)page
{
//    [self.queueViewController.navigationController setNavigationBarHidden:YES animated:NO];
    if (page < [self.queuesArray count])
    {
        QueueCell *cell = (QueueCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
        [cell setSelectable:YES animated:YES];
        [self.tableView performSelector:@selector(bringSubviewToFront:) withObject:cell afterDelay:0.4];
        //    [self.tableView bringSubviewToFront:cell];
//        NSLog(@"Can select page %d", page);
    }
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController canNoLongerSelectPage:(NSUInteger)page
{
    if (page < [self.queuesArray count])
    {
        QueueCell *cell = (QueueCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
        [cell setSelectable:NO animated:YES];
        [self.tableView performSelector:@selector(sendSubviewToBack:) withObject:cell afterDelay:0.4];
        //    [self.tableView sendSubviewToBack:cell];
//        NSLog(@"Can no longer select %d", page);
    }
}

- (void)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController hasIntersectedSelectedPage:(NSUInteger)page
{
//    self.queueViewController.navigationController.navigationBar.alpha = 1.0;
    [self setNavigationBar:self.queueViewController.navigationController.navigationBar alpha:1.0 withDuration:0.25];
}

- (void)pullNavigationControllerHasBeenDismissed:(LLPullNavigationController *)pullNavigationViewController
{
    [self updateAllCellsWithEmphasis:YES animated:YES];
    [self showNewQueueSectionWithAnimation:YES];
}

- (NSString *)pullNavigationController:(LLPullNavigationController *)pullNavigationViewController nameForViewAtPage:(NSUInteger)page
{
    if (page == 0)
    {
        return @"Pull to switch queues";
    }
    
    if (page < [self.queuesArray count])
    {
        Queue *queue = [self.queuesArray objectAtIndex:page];
        return [NSString stringWithFormat:@"Release to switch\nto your %@ queue", queue.name];
    }
    
    return @"Release to see all queues";
}

- (NSString *)pullNavigationControllerNameForShouldDismissInstruction:(LLPullNavigationController *)pullNavigationViewController
{
    return @"Release to see all queues";
}

- (void)switchToQueueAtIndex:(NSInteger)index
{
    // If the selected queue doesn't exist, choose the queue at the highest index allowed instead
    if (index >= [self.queuesArray count])
    {
        index = [self.queuesArray count] - 1;
    }
    
    // Resign first responder in case one of the queue names is being edited
    [self endQueueNameEditing];
    
    // Make sure the new queue field is hidden
    [self hideNewQueueSectionWithAnimation:YES];
    
    UINavigationController *navController;
    if ([[self.queueViewControllersArray objectAtIndex:index] isEqual:[NSNull null]])
    {
        QueueViewController *queueView = [[QueueViewController alloc] initWithQueue:[self.queuesArray objectAtIndex:index]];
        queueView.managedObjectContext = self.managedObjectContext;
        queueView.title = [[self.queuesArray objectAtIndex:index] name];
        
        self.queueViewController = queueView;
        
        navController = [[UINavigationController alloc] initWithRootViewController:queueView];
        navController.navigationBar.barTintColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
        [self.queueViewControllersArray replaceObjectAtIndex:index withObject:navController];
    }
    else
    {
        navController = [self.queueViewControllersArray objectAtIndex:index];
        self.queueViewController = [[navController viewControllers] objectAtIndex:0];
    }
    
//    QueueViewController *queueView = [[QueueViewController alloc] initWithQueue:[self.queuesArray objectAtIndex:index]];
//    queueView.managedObjectContext = self.managedObjectContext;
//    queueView.title = [[self.queuesArray objectAtIndex:index] name];
//    
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:queueView];
//    [queueView.navigationController setNavigationBarHidden:NO animated:NO];
    LLPullNavigationController *pullController = (LLPullNavigationController *)self.parentViewController;
//    queueView.navigationController.navigationBar.alpha = 0.0;
    [pullController switchToViewController:navController atPage:index animated:YES completion:nil];
//    [self setNavigationBar:queueView.navigationController.navigationBar alpha:0.0 withDuration:0.0];
    
    [self sendQueueAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] toTopOfListWithDelay:0.5];
    selectedQueue = 0;
}

- (void)sendQueueAtIndexPath:(NSIndexPath *)indexPath toTopOfListWithDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(sendQueueAtIndexPathToTopOfList:) withObject:indexPath afterDelay:delay];
}

- (void)sendQueueAtIndexPathToTopOfList:(NSIndexPath *)indexPath
{
    [self tableView:self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark Queue Creation

// -----------------------------------------
// Hide the new queue section by changing
// the table's offset
// -----------------------------------------
- (void)hideNewQueueSectionWithAnimation:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, rowHeight) animated:animated];
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

// -----------------------------------------
// Show the new queue section by changing
// the table's offset
// -----------------------------------------
- (void)showNewQueueSectionWithAnimation:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:animated];
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// -----------------------------------------
// Create a new queue when the user is
// done editing the name
// -----------------------------------------
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        [self addQueueWithName:textField.text];
        [self hideNewQueueSectionWithAnimation:NO];
    }
    else {
        [self hideNewQueueSectionWithAnimation:YES];
    }
    textField.text = @"";
}

#pragma mark Queue Name Editing

// -----------------------------------------
// End editing for any of the queue names
// that may be in edit state
// -----------------------------------------
- (void)endQueueNameEditing
{
    for (Queue *queue in self.queuesArray)
    {
        QueueCell *cell = (QueueCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.queuesArray indexOfObject:queue] inSection:0]];
        if (cell.queueNameLabel.isFirstResponder)
            [cell.queueNameLabel resignFirstResponder];
    }
    
    if ([self.queueNameTextField isFirstResponder])
        [self.queueNameTextField resignFirstResponder];
}

// -----------------------------------------
// Update the edit queue with its new name
// -----------------------------------------
- (void)queueCell:(QueueCell *)cell didEndNameEditingWithNewName:(NSString *)name
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Queue *queue = [self.queuesArray objectAtIndex:indexPath.row];
    queue.name = name;
    [self saveQueueData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    
    // Hide the create new queue section
//    [self hideNewQueueSectionWithAnimation:NO];
}

#pragma mark Queue Position Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    Queue *queue = [self.queuesArray objectAtIndex:fromIndexPath.row];
    UINavigationController *navController = [self.queueViewControllersArray objectAtIndex:fromIndexPath.row];
    
    [self.queuesArray removeObjectAtIndex:fromIndexPath.row];
    [self.queueViewControllersArray removeObjectAtIndex:fromIndexPath.row];
    
    [self.queuesArray insertObject:queue atIndex:toIndexPath.row];
    [self.queueViewControllersArray insertObject:navController atIndex:toIndexPath.row];
    
    [tableView reloadData];
}

# pragma mark - Queue Deletion Methods

// -----------------------------------------
// Respond to cell swiping in order to
// - Update the delete instruction
// - Close any currently open deletion cells
// -----------------------------------------
- (void)swipeyCell:(QueueCell *)cell didDragToPoint:(CGPoint)point
{
    if (_cellForDeletion && ![_cellForDeletion isEqual:cell])
        [_cellForDeletion resetCellWithAnimation:YES];
    
    _cellForDeletion = cell;
    
    if (ABS(point.x) > cell.dragThreshold)
        cell.deleteLabel.text = @"Release to delete";
    else
        cell.deleteLabel.text = @"Swipe to delete";
}

// -----------------------------------------
// Prevent table scrolling when in delete mode
// -----------------------------------------
- (void)swipeyCellDidBeginDragging:(LLSwipeyCell *)cell
{
    _tableView.scrollEnabled = NO;
}

// -----------------------------------------
// Re-enable table scrolling after delete mode
// -----------------------------------------
- (void)swipeyCellDidReset:(LLSwipeyCell *)cell
{
    _tableView.scrollEnabled = YES;
}

- (void)swipeyCellDidDismiss:(QueueCell *)cell
{
    _tableView.scrollEnabled = YES;
    cell.deleteLabel.text = @"Seriously, delete this queue?";
}

// -----------------------------------------
// Delete a queue
// -----------------------------------------
- (void)queueCellDidDeleteQueue:(QueueCell *)cell
{
    // Get the queue that has been deleted
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    Queue *queue = [_queuesArray objectAtIndex:indexPath.row];
    
    // Remove the queue object from our array and from memory
    [_queuesArray removeObject:queue];
    [_managedObjectContext deleteObject:queue];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
    
    // Animate the cell out of the table
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

# pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_cellForDeletion)
        [_cellForDeletion resetCellWithAnimation:YES];
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
    tableView.allowsSelectionDuringEditing = YES;
    tableView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
    
    UIView *newQueueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, rowHeight)];
    
    CGRect nameFrame = CGRectMake(newQueueView.bounds.origin.x + NAME_LABEL_MARGIN_LEFT,
                                  newQueueView.bounds.origin.y + NAME_LABEL_MARGIN_TOP,
                                  tableView.frame.size.width - (NAME_LABEL_MARGIN_LEFT + NAME_LABEL_MARGIN_RIGHT),
                                  newQueueView.frame.size.height - (NAME_LABEL_MARGIN_TOP + NAME_LABEL_MARGIN_BOTTOM));
    
    UITextField *queueNameLabel = [[UITextField alloc] initWithFrame:nameFrame];
    queueNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
    queueNameLabel.textAlignment = NSTextAlignmentCenter;
    queueNameLabel.backgroundColor = [UIColor clearColor];
    queueNameLabel.delegate = self;
    queueNameLabel.placeholder = @"New Queue";
    queueNameLabel.layer.shadowOpacity = 1.0;
    queueNameLabel.layer.shadowRadius = 1.0;
    queueNameLabel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
    queueNameLabel.layer.shadowOffset = CGSizeMake(0.0, -1.0);
    queueNameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [queueNameLabel setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
    self.queueNameTextField = queueNameLabel;
    
    [newQueueView addSubview:self.queueNameTextField];
    tableView.tableHeaderView = newQueueView;
    
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
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

    [self setQueuesArray:mutableFetchResults];
    
    self.queueViewControllersArray = [NSMutableArray arrayWithCapacity:[self.queuesArray count]];
    for (int i = 0; i < [self.queuesArray count]; i++)
        [self.queueViewControllersArray addObject:[NSNull null]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
