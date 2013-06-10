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
#import "LLPullNavigationController.h"

@interface QueuesViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *queuesArray;

@end

@implementation QueuesViewController

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QueueRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:QueueRowIdentifier];
    }
    Queue *queue = (Queue *)[self.queuesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = queue.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

# pragma mark - Queue Row Selection Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueueViewController *queueView = [[QueueViewController alloc] initWithQueue:[self.queuesArray objectAtIndex:indexPath.row]];
    queueView.managedObjectContext = self.managedObjectContext;
    queueView.title = [[self.queuesArray objectAtIndex:indexPath.row] name];
//    [self.navigationController pushViewController:queueView animated:YES];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:queueView];
    LLPullNavigationController *pullController = (LLPullNavigationController *)self.parentViewController;
    [pullController switchToViewController:navController animated:YES completion:nil];
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	
    // Create a table view to hold the contacts
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
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
