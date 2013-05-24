//
//  QueueViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/16/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueViewController.h"
#import "TimelineViewController.h"
#import "QueueContactCell.h"
#import "QueueBarButtonItem.h"
#import "Contact.h"
#import "Queue.h"

@interface QueueViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) Contact * selectedContact;

@property BOOL isScrollingToNewContact;

@end

@implementation QueueViewController

# pragma mark - Initialization Methods

- (id)initWithQueue:(Queue *)queue
{
    if (self = [super init])
    {
        self.queue = queue;
    }
    return self;
}

# pragma mark - Contact Importing Methods

- (void)importContact
{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([navigationController isKindOfClass:[ABPeoplePickerNavigationController class]])
    {
        QueueBarButtonItem *cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(peoplePickerNavigationControllerDidCancel:)];
        navigationController.topViewController.navigationItem.rightBarButtonItem = cancelButton;
    }
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    Contact *newContact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                                   inManagedObjectContext:_managedObjectContext];
    [newContact populateWithAddressBookRecord:person];
    
    // Make sure the contact isn't already in the queue
    if ([_queue containsContact:newContact])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is already in your queue", newContact.fullName]
                                                        message:@"Perhaps you meant to choose a different contact?"
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    // Otherwise, add the contact to the queue
    else
    {
        [_queue addContactsObject:newContact];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [self updateContactsArrayWithTableReload:NO];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.contactsArray indexOfObject:newContact] inSection:0];
            
            [self dismissViewControllerAnimated:YES completion:^{[self insertRowAtIndexPath:newIndexPath];}];
        }
        
    }
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

#pragma mark - Meeting Management Methods

// -------------------------------------------------------------
// Animate the repositioning of a contact
// after a meeting is created
// -------------------------------------------------------------
- (void)repositionSelectedContact
{
    // Get the contact's current queue position
    NSInteger oldRow = [self.contactsArray indexOfObject:self.selectedContact];
    NSIndexPath *oldPosition = [NSIndexPath indexPathForRow:oldRow inSection:0];
    
    // Update the contacts array
    [self updateContactsArrayWithTableReload:NO];
    
    // Get the contact's new position
    NSInteger newRow = [self.contactsArray indexOfObject:self.selectedContact];
    NSIndexPath *newPosition = [NSIndexPath indexPathForRow:newRow inSection:0];
    
    // Animate the position change
    if (oldRow != newRow) {
        [self sendContactToNewPosition:newPosition fromOldPosition:oldPosition animated:YES];
    } else {
        [self sendContactToNewPosition:newPosition fromOldPosition:oldPosition animated:NO];
    }
}

# pragma mark - Queue Display Methods

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Only perform this animation once the view has scrolled to the new contact
    // This method will continue to call itself every few milliseconds until
    // the view has finished scrolling
    
    NSIndexPath *scrollToIndexPath;
    if (indexPath.row == [self.contactsArray count] - 1)
        scrollToIndexPath = [NSIndexPath indexPathForRow:[self.contactsArray count] - 2 inSection:0];
    else
        scrollToIndexPath = indexPath;
    
    if (![self.tableView.indexPathsForVisibleRows containsObject:scrollToIndexPath])
    {
        self.isScrollingToNewContact = YES;
        [self.tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    
    if (self.isScrollingToNewContact)
        [self performSelector:@selector(insertRowAtIndexPath:) withObject:indexPath afterDelay:50];
    else
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)updateContactsArrayWithTableReload:(BOOL)shouldReload
{
    self.contactsArray = [NSMutableArray arrayWithArray:[self.queue sortedContacts]];
    if (shouldReload) [_tableView reloadData];
}

- (void)sendContactToNewPosition:(NSIndexPath *)newPosition fromOldPosition:(NSIndexPath *)oldPosition animated:(BOOL)animated
{
    if (animated) {
        [self.tableView beginUpdates];
        
        if ([self.contactsArray count] > 1) {
            [self.tableView deleteRowsAtIndexPaths:@[oldPosition] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView insertRowsAtIndexPaths:@[newPosition] withRowAnimation:UITableViewRowAnimationLeft];
        }
        
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
    
}

// --------------------------------------------------------
// Understand when the table view has stopped scrolling
// to a just-added contact so the new row will be
// in view when it is inserted
// --------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.isScrollingToNewContact)
    {
        self.isScrollingToNewContact = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactRowIdentifier = @"ContactRowIdentifier";
    QueueContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactRowIdentifier];
    if (cell == nil) {
        cell = [[QueueContactCell alloc] initWithReuseIdentifier:ContactRowIdentifier];
    }
    
    [cell configureWithContact:[self.contactsArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
}

# pragma mark - Queue Row Selection Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    TimelineViewController *timelineView = [[TimelineViewController alloc] initWithContact:[self.contactsArray objectAtIndex:indexPath.row]];
    timelineView.managedObjectContext = self.managedObjectContext;
    timelineView.title = [NSString stringWithFormat:@"Meetings"];
    [self.navigationController pushViewController:timelineView animated:YES];
    
    self.selectedContact = [self.contactsArray objectAtIndex:indexPath.row];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
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
    tableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    // Add the add contact button to the right side of the nav bar
    QueueBarButtonItem *addContactButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeAdd target:self action:@selector(importContact)];
    self.navigationItem.rightBarButtonItem = addContactButton;
    
    QueueBarButtonItem *backButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeBack target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self updateContactsArrayWithTableReload:NO];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)viewDidAppear:(BOOL)animated
{
    // See whether we need to reposition the contact we were just viewing
    if (self.selectedContact)
    {
        [self repositionSelectedContact];
    }
    self.selectedContact = nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end