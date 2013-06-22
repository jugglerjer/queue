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

#define NAME_LABEL_MARGIN_RIGHT     20
#define NAME_LABEL_MARGIN_LEFT      20
#define NAME_LABEL_MARGIN_TOP       6
#define NAME_LABEL_MARGIN_BOTTOM    6

@interface QueuesViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *queueNameTextField;
@property (nonatomic) NSMutableArray *queuesArray;
@property (weak, nonatomic) QueueViewController *queueViewController;

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
        [self.queuesArray insertObject:newQueue atIndex:0];
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
    
    // Resign first responder in case one of the queue names is being edited
    [self endQueueNameEditing];
    
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

#pragma mark Queue Creation

// -----------------------------------------
// Hide the new queue section by changing
// the table's offset
// -----------------------------------------
- (void)hideNewQueueSectionWithAnimation:(BOOL)animated
{
//    [self.tableView setContentOffset:CGPointMake(0, rowHeight) animated:animated];
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
    }
    
    textField.text = @"";
    [self hideNewQueueSectionWithAnimation:NO];
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
    [self hideNewQueueSectionWithAnimation:NO];
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
    
    CGRect nameFrame = CGRectMake(NAME_LABEL_MARGIN_LEFT,
                                  NAME_LABEL_MARGIN_TOP,
                                  tableView.frame.size.width - (NAME_LABEL_MARGIN_LEFT + NAME_LABEL_MARGIN_RIGHT),
                                  44.0 - (NAME_LABEL_MARGIN_TOP + NAME_LABEL_MARGIN_BOTTOM));
    
    UITextField *queueNameLabel = [[UITextField alloc] initWithFrame:nameFrame];
    queueNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
    queueNameLabel.textAlignment = NSTextAlignmentCenter;
    queueNameLabel.backgroundColor = [UIColor clearColor];
    queueNameLabel.delegate = self;
    queueNameLabel.placeholder = @"New Queue";
    queueNameLabel.layer.shadowOpacity = 1.0;
    queueNameLabel.layer.shadowRadius = 0.0;
    queueNameLabel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
    queueNameLabel.layer.shadowOffset = CGSizeMake(0.0, -1.0);
    queueNameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [queueNameLabel setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
    self.queueNameTextField = queueNameLabel;
    tableView.tableHeaderView = self.queueNameTextField;
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
