//
//  QueueViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/16/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "QueueViewController.h"
#import "TimelineViewController.h"
#import "QueueBarButtonItem.h"
#import "Contact.h"
#import "Queue.h"
#import "Meeting.h"
#import "LLPullNavigationController.h"
#import "LLPullNavigationTableView.h"
#import "LLPullNavigationScrollView.h"
#import "QueuesViewController.h"
#import "ContactChooserViewController.h"

@interface QueueViewController ()

@property (nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) TimelineViewController *timeline;
@property (strong, nonatomic) QueueBarButtonItem *addButton;

@property (strong, nonatomic) UIPanGestureRecognizer *navBarGesture;
//@property (strong, nonatomic) UIPanGestureRecognizer *tableGesture;

@property BOOL isScrollingToNewContact;
@property BOOL isTimelineExpanded;
@property BOOL isOutOfBounds;

@property (nonatomic) NSMutableDictionary *imagesDictionary;

@end

@implementation QueueViewController

static CGFloat contactRowHeight = 72.0f;
#define degreesToRadians(x) (M_PI * x / 180.0)
CGPoint previousContentOffset;
BOOL isScrollingDown;

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
    
//    ContactChooserViewController *picker = [[ContactChooserViewController alloc] initWithStyle:UITableViewStylePlain];
//    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:picker];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([navigationController isKindOfClass:[ABPeoplePickerNavigationController class]])
    {
        if (![viewController isKindOfClass:[AddContactViewController class]])
        {
            QueueBarButtonItem *cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(peoplePickerNavigationControllerDidCancel:)];
            navigationController.topViewController.navigationItem.leftBarButtonItem = cancelButton;
            navigationController.topViewController.navigationItem.rightBarButtonItem = nil;
        }
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
//        [_queue addContactsObject:newContact];
//        NSError *error = nil;
//        if (![self.managedObjectContext save:&error]) {
//            // Handle the error.
//            [self dismissViewControllerAnimated:YES completion:NULL];
//        } else {
//            [self updateContactsArrayWithTableReload:NO];
//            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.contactsArray indexOfObject:newContact] inSection:0];
//            
//            [self dismissViewControllerAnimated:YES completion:^{[self insertRowAtIndexPath:newIndexPath];}];
//        }
        // Show the add contact view controller
        // so the user can configure settings
        AddContactViewController *addContactController = [[AddContactViewController alloc] init];
        addContactController.managedObjectContext = self.managedObjectContext;
        addContactController.contact = newContact;
        addContactController.delegate = self;
        addContactController.editContactType = QueueEditContactTypeAdd;
        
        [peoplePicker pushViewController:addContactController animated:YES];
        
    }
    return NO;
}

- (void)addContactViewController:(AddContactViewController *)addContactViewController didUpdateContact:(Contact *)contact
{
    [_queue addContactsObject:contact];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    } else {
        [self updateContactsArrayWithTableReload:NO];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.contactsArray indexOfObject:contact] inSection:0];
        [self insertRowAtIndexPath:newIndexPath];
    }
}

- (void)addContactViewController:(AddContactViewController *)addContactViewController didDismissWithoutUpdatingContact:(Contact *)contact
{
    [self.managedObjectContext deleteObject:contact];
}

//- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
//      shouldContinueAfterSelectingPerson:(ABRecordRef)person
//                                property:(ABPropertyID)property
//                              identifier:(ABMultiValueIdentifier)identifier
//{
//    return NO;
//}

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

- (void)queueContactCell:(QueueContactCell *)cell didDismissWithType:(QueueContactCellDismissalType)type
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Contact *contact = [self.contactsArray objectAtIndex:indexPath.row];
    Meeting *newMeeting = (Meeting *)[NSEntityDescription insertNewObjectForEntityForName:@"Meeting"
                                                                   inManagedObjectContext:_managedObjectContext];
    switch (type) {
        case QueueContactCellDismissalTypeQueue:
            newMeeting.date = [NSDate date];
            newMeeting.note = @"Queued";
            newMeeting.method = @"queue";
            break;
            
        case QueueContactCellDismissalTypeSnooze:
            newMeeting.date = [NSDate date];
            newMeeting.note = @"Snoozed";
            newMeeting.method = @"snooze";
            break;
            
        default:
            newMeeting.date = [NSDate date];
            newMeeting.note = @"Queued";
            newMeeting.method = @"queue";
            break;
    }
    
    
    [contact addMeetingsObject:newMeeting];
    self.selectedIndexPath = indexPath;
    
    CGFloat delay = 0.5;
    [self performSelector:@selector(repositionSelectedContact) withObject:nil afterDelay:delay];
    [cell performSelector:@selector(resetCellPositionWithAnimation:) withObject:nil afterDelay:delay + 0.25];
//    [self repositionSelectedContact];
//    int newRow = [self.contactsArray indexOfObject:contact];
    
//    if (indexPath.row == newRow)
//        duration = 0.0;
//    else
//        duration = 0.0;
    
    
}

- (void)queueContactCellDidBeginDragging:(QueueContactCell *)cell
{
    self.tableView.scrollEnabled = NO;
}

- (void)queueContactCellDidEndDragging:(QueueContactCell *)cell
{
    self.tableView.scrollEnabled = YES;
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
    
    cell.delegate = self;
    Contact *contact = [self.contactsArray objectAtIndex:indexPath.row];
    UIImage *image = [_imagesDictionary objectForKey:[NSNumber numberWithInteger:[contact hash]]];
    if (!image)
    {
//        image = [cell avatarImageForContact:contact];
        [cell performSelectorInBackground:@selector(setAvatarImageForContact:) withObject:contact];
//        [_imagesDictionary setObject:image forKey:indexPath];
    }
    
    [cell configureWithContact:[self.contactsArray objectAtIndex:indexPath.row] andImage:image];
    CGRect frame = cell.bounds;
    frame.size.height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    frame.size.width = cell.frame.size.width;
    frame.origin.x = 0;
    cell.backgroundWell.frame = frame;
    [cell bringSubviewToFront:cell.contentView];
    
    return cell;
}

- (void)queueContactCell:(QueueContactCell *)cell didSetImage:(UIImage *)image forContact:(Contact *)contact
{
    [_imagesDictionary setObject:image forKey:[NSNumber numberWithInteger:[contact hash]]];
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

// -----------------------------------------
// Determine which direction the scroll view
// is scrolling in so that we can tell whether
// or not to switch pages on a didEndDragging call
// -----------------------------------------
- (BOOL)isScrollingDown
{
    BOOL isScrollingDown;
    CGPoint currentContentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y);
    if (currentContentOffset.y < previousContentOffset.y)
        isScrollingDown = YES;
    else
        isScrollingDown = NO;
    
    return isScrollingDown;
}

// -----------------------------------------
// Prepare for queue selection mode when
// The user begins dragging the table
// -----------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"%f, %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if (scrollView.contentOffset.y <= 0)
    {
        [pullController assumeScrollControl];
        [pullController enterSelectionMode];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if (scrollView.contentOffset.y < 0)
    {
        
        isScrollingDown = YES;
        if (pullController.isEngaged)
        {
//            [pullController assumeScrollControl];
//            self.navigationController.navigationBar.alpha = 0.0;
            [UIView animateWithDuration:0.0 animations:^{self.navigationController.navigationBar.alpha = 0.0;}];
            //        [self.navigationController setNavigationBarHidden:YES animated:NO];
            //        [pullController.scrollView setTransform:CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y)];
            CGRect bounds = scrollView.bounds;
            [pullController.scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y + pullController.scrollView.frame.size.height)];
            bounds.origin.y = scrollView.contentOffset.y;
            [scrollView setBounds:bounds];
            //        [self.navigationController.view setTransform:CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y)];
            [self.view setTransform:CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y)];
            //        [self.tableView setTransform:CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y)];
        }
    }
    else {
//        self.navigationController.navigationBar.alpha = 1.0;
        isScrollingDown = NO;
        [pullController exitSelectionMode];
        [pullController resignScrollControl];
        [UIView animateWithDuration:0.25 animations:^{self.navigationController.navigationBar.alpha = 1.0;}];
    }
}

// -----------------------------------------
// Prepare for queue selection mode when
// The user begins dragging the table
// -----------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if (isScrollingDown && pullController.isEngaged)
    {
        
        [pullController exitSelectionMode];
        if ([pullController shouldDismissScrollView])
        {
            NSLog(@"Should dismiss scroll view");
            [pullController resignScrollControl];
            [pullController dismissScrollView];
        }
        else
        {
            NSLog(@"Should switch queues");
            [pullController shouldSwitchViewControllers];
        }
    }
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
    [self rotateRightNavButtonToClose];
    [self.tableView insertRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [self.addButton setEnabled:NO];
}

- (void)hideTimelineWithContactReposition:(BOOL)reposition
{
    // Contract the cell to hide the timeline
    self.isTimelineExpanded = NO;
    NSIndexPath *timelineIndexPath = [self timelineIndexPath];
//    [self slideTimelineUp];
//    [self performSelector:@selector(slideTimeline) withObject:nil afterDelay:0.4];
    [self rotateRightNavButtonToAdd];
    [self.tableView deleteRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    self.tableView.scrollEnabled = YES;
    
    if (reposition)
        [self performSelector:@selector(repositionSelectedContact) withObject:nil afterDelay:0.4];
    
    [self.timeline hideToolbelt];
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

- (void)rightNavButtonTapped
{
    if (self.isTimelineExpanded)
    {
        [self hideTimelineWithContactReposition:YES];
    }
    else
    {
        [self importContact];
    }
}

- (void)rotateRightNavButtonToClose
{
    UIButton *button = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    UIImageView *imageView = button.imageView;
    [UIView animateWithDuration:0.3 animations:^{
        imageView.center = button.center;
        imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(45.0));
    } completion:^(BOOL finished){
//        self.navigationItem.rightBarButtonItem.customView.frame = frame;
    }];
}

- (void)rotateRightNavButtonToAdd
{
    UIButton *button = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    UIImageView *imageView = button.imageView;
    [UIView animateWithDuration:0.3 animations:^{
        imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(0.0));
    } completion:^(BOOL finished){
        //        self.navigationItem.rightBarButtonItem.customView.frame = frame;
    }];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

# pragma mark - View Management Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // A a gesture recognizer to the navigation bar to let the user pull to switch queues using its area
//    UIPanGestureRecognizer *navBarGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(<#selector#>)];
    
    self.view.backgroundColor = [UIColor clearColor];
	
    // Create a table view to hold the contacts
    LLPullNavigationTableView *tableView = [[LLPullNavigationTableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y/* + self.navigationController.navigationBar.frame.size.height*/,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
//    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.delaysContentTouches = NO;
    
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    // Add the add contact button to the right side of the nav bar
    QueueBarButtonItem *addContactButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeAdd target:self action:@selector(rightNavButtonTapped)];
    self.addButton = addContactButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
//    QueueBarButtonItem *backButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeBack target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = backButton;
    
    [self updateContactsArrayWithTableReload:NO];
    _imagesDictionary = [NSMutableDictionary dictionaryWithCapacity:[self.contactsArray count]];
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
