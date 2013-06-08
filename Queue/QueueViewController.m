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

@property (nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) TimelineViewController *timeline;
@property (strong, nonatomic) QueueBarButtonItem *addButton;

@property BOOL isScrollingToNewContact;
@property BOOL isTimelineExpanded;

@end

@implementation QueueViewController

static CGFloat contactRowHeight = 72.0f;

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

#pragma mark - Contact Management Methods

// -------------------------------------------------------------
// Update a contact row
// after a meeting is created or updated
// or their settings are changed
// -------------------------------------------------------------
- (void)timelineViewController:(TimelineViewController *)timelineViewController didUpdateContact:(Contact *)contact withMeeting:(Meeting *)meeting
{
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

// -------------------------------------------------------------
// Delete a contact once the user confirms their removal
// -------------------------------------------------------------
- (void)timelineViewController:(TimelineViewController *)timelineViewController shouldDeleteContact:(Contact *)contact
{
    [self.queue removeContactsObject:contact];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    } else {
        [self hideTimelineWithContactReposition:NO];
        [self performSelector:@selector(updateContactsArrayWithTableReload:) withObject:NO afterDelay:0.4];
        [self performSelector:@selector(deleteRowAtIndexPath:) withObject:self.selectedIndexPath afterDelay:0.4];
    }
}

// -------------------------------------------------------------
// Animate the repositioning of a contact
// after a meeting is created
// -------------------------------------------------------------
- (void)repositionSelectedContact
{
    // Get the contact's current queue position
//    NSInteger oldRow = [self.contactsArray indexOfObject:self.selectedContact];
//    NSIndexPath *oldPosition = [NSIndexPath indexPathForRow:oldRow inSection:0];
    NSIndexPath *oldPosition = self.selectedIndexPath;
    Contact *contact = [self.contactsArray objectAtIndex:self.selectedIndexPath.row];
    
    // Update the contacts array
    [self updateContactsArrayWithTableReload:NO];
    
    // Get the contact's new position
    NSInteger newRow = [self.contactsArray indexOfObject:contact];
    NSIndexPath *newPosition = [NSIndexPath indexPathForRow:newRow inSection:0];
    
    self.selectedIndexPath = nil;
    
    // Animate the position change
    if (oldPosition.row != newRow) {
        [self sendContactToNewPosition:newPosition fromOldPosition:oldPosition animated:YES];
    } else {
        [self sendContactToNewPosition:newPosition fromOldPosition:oldPosition animated:NO];
    }
}

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
    
    if ([self.contactsArray count] > 1)
    {
        [self.tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        if ([self.tableView.indexPathsForVisibleRows containsObject:scrollToIndexPath])
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        else
            [self performSelector:@selector(insertRowAtIndexPath:) withObject:scrollToIndexPath afterDelay:50];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }

}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)scrollToNearestRowForIndexPath:(NSIndexPath *)indexPath
{
    
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

# pragma mark - Queue Display Methods

// --------------------------------------------------------
// Understand when the table view has stopped scrolling
// to a just-added contact so the new row will be
// in view when it is inserted
// --------------------------------------------------------
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (self.isScrollingToNewContact)
//    {
//        self.isScrollingToNewContact = NO;
//    }
//}

- (NSIndexPath *)timelineIndexPath
{

    return [NSIndexPath indexPathForRow:self.selectedIndexPath.row + 1 inSection:0];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isTimelineExpanded)
        return [self.contactsArray count] + 1;
    return [self.contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return a special timeline cell if the timeline is expanded and we're
    // one row beneath the selected cell
    if (self.isTimelineExpanded && [indexPath isEqual:[self timelineIndexPath]])
    {
        static NSString *TimelineRowIdentifier = @"TimelineRowIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TimelineRowIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimelineRowIdentifier];
        }
        
        TimelineViewController *timelineView = [[TimelineViewController alloc] initWithContact:[self.contactsArray objectAtIndex:indexPath.row - 1]];
        timelineView.managedObjectContext = self.managedObjectContext;
        timelineView.queueViewController = self;
        timelineView.delegate = self;
        CGRect frame = cell.bounds;
        frame.size.height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
//        frame.origin.y -= frame.size.height;
        timelineView.view.frame = frame;
        self.timeline = timelineView;
        [cell addSubview:timelineView.view];
//        cell.clipsToBounds = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    // Otherwise, just return a normal contact cell
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
    if (self.isTimelineExpanded && [indexPath isEqual:[self timelineIndexPath]])
        return self.tableView.frame.size.height - contactRowHeight;
    return contactRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tableTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.5)];
    tableTopLine.backgroundColor = [UIColor blackColor];
    tableTopLine.alpha = 0.1;
    return tableTopLine;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.5)];
    footer.backgroundColor = [UIColor whiteColor];
    footer.alpha = 0.2;
    return footer;
}

# pragma mark - Queue Row Selection Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isTimelineExpanded && [indexPath isEqual:[self timelineIndexPath]])
        return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{        
    if (self.isTimelineExpanded && [self.selectedIndexPath isEqual:indexPath])
    {
        [self hideTimelineWithContactReposition:YES];
    }
    else
    {
        [self showTimelineWithIndexPath:indexPath];
    }
}

- (void)showTimelineWithIndexPath:(NSIndexPath *)indexPath
{
    // Expand the height of the selected cell to expose enough room for the timeline
    self.isTimelineExpanded = YES;
    self.selectedIndexPath = indexPath;
    self.tableView.scrollEnabled = NO;
    NSIndexPath *timelineIndexPath = [self timelineIndexPath];
//    [self slideTimelineDown];
//    [self performSelector:@selector(slideTimeline) withObject:nil afterDelay:0.4];
    [self.tableView insertRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.addButton setEnabled:NO];
}

- (void)hideTimelineWithContactReposition:(BOOL)reposition
{
    // Contract the cell to hide the timeline
    self.isTimelineExpanded = NO;
    NSIndexPath *timelineIndexPath = [self timelineIndexPath];
//    [self slideTimelineUp];
//    [self performSelector:@selector(slideTimeline) withObject:nil afterDelay:0.4];
    [self.tableView deleteRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    self.tableView.scrollEnabled = YES;
    
    if (reposition)
        [self performSelector:@selector(repositionSelectedContact) withObject:nil afterDelay:0.4];
    
    [self.timeline.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4];
    [self.addButton setEnabled:YES];
}

- (void)slideTimelineDown
{
    CGRect frame = self.timeline.view.frame;
    frame.origin.y = frame.origin.y + frame.size.height;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.timeline.view.frame = frame;
                     }];
}

- (void)slideTimelineUp
{
    CGRect frame = self.timeline.view.frame;
    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.timeline.view.frame = frame;
                     }];
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
    self.addButton = addContactButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
