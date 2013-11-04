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
#import "Location.h"
#import "LLPullNavigationController.h"
#import "LLPullNavigationTableView.h"
#import "LLPullNavigationScrollView.h"
#import "QueuesViewController.h"
#import "ContactChooserViewController.h"
#import "NSObject+Blocks.h"

@interface QueueViewController ()

@property (nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) TimelineViewController *timeline;
@property (strong, nonatomic) QueueBarButtonItem *addButton;
@property (strong, nonatomic) LLPullNavigationController *pullController;

@property (strong, nonatomic) UIPanGestureRecognizer *navBarGesture;
//@property (strong, nonatomic) UIPanGestureRecognizer *tableGesture;

@property (strong, nonatomic) Meeting *defaultMeeting;
@property (strong, nonatomic) LLLocationManager *locationManager;

// Store the table view's bounds before and after
// expanding the timeline in order to animate back
// to that position once the timeline is removed
@property CGRect contractedBounds;
@property CGRect expandedBounds;

// Store the indexPath of a new contact in order to
// insert the given row after animating to its position
@property (strong, nonatomic) NSIndexPath *addedContactIndexPath;

@property BOOL isScrollingToNewContact;
@property BOOL isTimelineExpanded;
@property BOOL hasTimelineAnimated;
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
    picker.navigationBar.barTintColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:188.0/255.0 alpha:1];
    
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

- (void)queueContactCell:(QueueContactCell *)cell didDismissWithType:(QueueContactCellDismissalType)type andMeeting:(Meeting *)meeting
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Contact *contact = [self.contactsArray objectAtIndex:indexPath.row];
    
    if (!meeting)
        meeting = (Meeting *)[NSEntityDescription insertNewObjectForEntityForName:@"Meeting"
                                                                   inManagedObjectContext:_managedObjectContext];
    switch (type) {
        case QueueContactCellDismissalTypeQueue:
            meeting.date = [NSDate date];
            meeting.note = @"Queued";
            meeting.method = @"queue";
            break;
            
        case QueueContactCellDismissalTypeSnooze:
            meeting.date = [NSDate date];
            meeting.note = @"Snoozed";
            meeting.method = @"snooze";
            break;
            
        case QueueContactCellDismissalTypeMeeting:
            break;
            
        default:
            meeting.date = [NSDate date];
            meeting.note = @"Queued";
            meeting.method = @"queue";
            break;
    }
    
    
    [contact addMeetingsObject:meeting];
    self.selectedIndexPath = indexPath;
    
    CGFloat delay = 0.5;
    [cell resetCellWithAnimation:YES];
    [self performSelector:@selector(repositionSelectedContact) withObject:nil afterDelay:delay];
//    [cell performSelector:@selector(resetCellWithAnimation:) withObject:nil afterDelay:delay + 0.25];
//    [self repositionSelectedContact];
//    int newRow = [self.contactsArray indexOfObject:contact];
    
//    if (indexPath.row == newRow)
//        duration = 0.0;
//    else
//        duration = 0.0;
    
    // Save the changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
}

- (void)queueContactCell:(QueueContactCell *)cell didRequestMeetingEditWithMeeting:(Meeting *)meeting
{
    AddMeetingViewController *addMeetingController = [[AddMeetingViewController alloc] initWithMeeting:meeting];
    addMeetingController.managedObjectContext = _managedObjectContext;
    addMeetingController.contact = [self.contactsArray objectAtIndex:[self.tableView indexPathForCell:cell].row];
    addMeetingController.delegate = self;
    addMeetingController.editMeetingType = QueueEditMeetingTypeUpdate;
    UINavigationController *navContoller = [[UINavigationController alloc] initWithRootViewController:addMeetingController];
    
    // Find the nearest navigation controller up the view hierarchy
    [self presentViewController:navContoller animated:YES completion:nil];
}

- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController didUpdateMeeting:(Meeting *)meeting forContact:(Contact *)contact
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.contactsArray indexOfObject:contact] inSection:0];
    QueueContactCell *cell = (QueueContactCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell configureWithMeeting:meeting];
}

- (void)swipeyCellDidBeginDragging:(QueueContactCell *)cell
{
    self.tableView.scrollEnabled = NO;
}

- (void)swipeyCellDidEndDragging:(QueueContactCell *)cell
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
    _addedContactIndexPath = indexPath;
    NSIndexPath *scrollToIndexPath;
    if (indexPath.row == [self.contactsArray count] - 1)
        scrollToIndexPath = [NSIndexPath indexPathForRow:[self.contactsArray count] - 2 inSection:0];
    else
        scrollToIndexPath = indexPath;
    
//    if ([self.contactsArray count] > 1)
//    {
//        _isScrollingToNewContact = YES;
//        [self.tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    
//        if ([self.tableView.indexPathsForVisibleRows containsObject:scrollToIndexPath])
//            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        else
//            [self performSelector:@selector(insertRowAtIndexPath:) withObject:indexPath afterDelay:50];
//    }
//    else
//    {
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    }
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

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
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.isScrollingToNewContact)
    {
        self.isScrollingToNewContact = NO;
        [self.tableView insertRowsAtIndexPaths:@[_addedContactIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

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
//        frame.size.height = 0;
//        [cell setFrame:frame];
        self.timeline = timelineView;
        [cell addSubview:timelineView.view];
        cell.clipsToBounds = YES;
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
    int contactIndex = _isTimelineExpanded && [self timelineIndexPath].row < indexPath.row ? indexPath.row - 1 : indexPath.row;
    Contact *contact = [self.contactsArray objectAtIndex:contactIndex];
    UIImage *image = [_imagesDictionary objectForKey:[NSNumber numberWithInteger:[contact hash]]];
    if (!image)
    {
//        image = [cell avatarImageForContact:contact];
        [cell performSelectorInBackground:@selector(setAvatarImageForContact:) withObject:contact];
//        [_imagesDictionary setObject:image forKey:indexPath];
    }
    
    [cell configureWithContact:contact andImage:image];
    [cell configureWithMeeting:_defaultMeeting];
    CGRect frame = cell.bounds;
    frame.size.height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    frame.size.width = cell.frame.size.width;
    frame.origin.x = 0;
    cell.backgroundWell.frame = frame;
    cell.underView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
//    [cell bringSubviewToFront:cell.contentView];
    
    return cell;
}

- (void)queueContactCell:(QueueContactCell *)cell didSetImage:(UIImage *)image forContact:(Contact *)contact
{
    [_imagesDictionary setObject:image forKey:[NSNumber numberWithInteger:[contact hash]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isTimelineExpanded && [indexPath isEqual:[self timelineIndexPath]])
    {
        if (_hasTimelineAnimated)
            return [self fullTimelineHeight];
        else
            return 0.0;
    }
    return contactRowHeight;
}

- (CGFloat)fullTimelineHeight
{
//    NSLog(@"%f", self.tableView.frame.size.height - contactRowHeight - [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.frame.size.height);
    return self.tableView.frame.size.height - contactRowHeight/* - [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.frame.size.height*/;
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

# pragma mark - Pull to Change Queue Methods

// -----------------------------------------
// Recognize a pull down gesture on the nav
// bar if it's in fact a pan downward
// -----------------------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer respondsToSelector:@selector(velocityInView:)])
    {
        CGPoint velocity = [gestureRecognizer velocityInView:self.navigationController.navigationBar.superview];
        if ( ABS(velocity.y) > ABS(velocity.x) && velocity.y > 0)
            return YES;
    }
    return NO;
}

// -----------------------------------------
// Activate pull to change queue with a tug
// on the navigation bar
// -----------------------------------------
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint distance = [gestureRecognizer translationInView:self.navigationController.navigationBar.superview];
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [pullController engageWithGestureRecognizer:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            if (pullController.isEngaged)
                [pullController adjustToPoint:CGPointMake(0, -distance.y)];
            break;
            
        case UIGestureRecognizerStateEnded:
            if (pullController.isEngaged)
            {
                [pullController disengageWithPotentialPageSwitch:YES];
                if (![pullController shouldDismissScrollView])
                    [pullController.scrollView setContentOffset:CGPointMake(0, pullController.scrollView.frame.size.height) animated:YES];
//                [UIView animateWithDuration:0.0 animations:^{self.navigationController.navigationBar.alpha = 1.0;}];
            }
            break;
            
        default:
            break;
    }

}

// -----------------------------------------
// Determine which direction the scroll view
// is scrolling in so that we can tell whether
// or not to switch pages on a didEndDragging call
// -----------------------------------------
//- (BOOL)isScrollingDown
//{
//    BOOL isScrollingDown;
//    CGPoint currentContentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y);
//    if (currentContentOffset.y < previousContentOffset.y)
//        isScrollingDown = YES;
//    else
//        isScrollingDown = NO;
//    
//    return isScrollingDown;
//}

// -----------------------------------------
// Prepare for queue selection mode when
// The user begins dragging the table
// -----------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if ([self.tableView.panGestureRecognizer velocityInView:[_tableView superview]].y > 0
        && scrollView.contentOffset.y <= -self.navigationController.navigationBar.frame.size.height)
    {
        [self prepareForQueueSelectionModeToBegin];
        [pullController engageWithGestureRecognizer:self.tableView.panGestureRecognizer];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Scroll View Offset: %f", scrollView.contentOffset.y);
    NSLog(@"Scroll View Inset: %f", scrollView.contentInset.top);
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if (scrollView.contentOffset.y < 0)
    {
        isScrollingDown = YES;
        if (pullController.isEngaged/* || pullController.isSwitchingToPage*/)
        {
            [pullController adjustToPoint:CGPointMake(0, scrollView.contentOffset.y)];
            [self.view setTransform:CGAffineTransformMakeTranslation(0, (scrollView.contentOffset.y + self.navigationController.navigationBar.frame.size.height))];
        }
    }
//    else
//    {
//        isScrollingDown = NO;
//        [pullController disengageWithPotentialPageSwitch:NO];
//        [self prepareForQueueSelectionModeToEnd];
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if (/*isScrollingDown && */pullController.isEngaged)
    {
        [pullController disengageWithPotentialPageSwitch:YES];
        if (pullController.isSwitchingToPage) {
            pullController.isEngaged = NO;
            [self prepareForQueueSelectionModeToEnd];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    LLPullNavigationController *pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
    if (scrollView.frame.origin.y != 0.0)
    {
        _pullController.isEngaged = NO;
        [self prepareForQueueSelectionModeToEnd];
    }
}

// -----------------------------------------
// Prepare for queue selection mode when
// The user begins dragging the table
// -----------------------------------------
- (void)prepareForQueueSelectionModeToBegin
{
//    [_tableView setTransform:CGAffineTransformMakeTranslation(0.0, _tableView.contentInset.top)];
    [UIView animateWithDuration:0.0 animations:^{self.navigationController.navigationBar.alpha = 0.0;}];
    [_tableView setContentInset:UIEdgeInsetsZero];
    _tableView.showsVerticalScrollIndicator = NO;
}

// -----------------------------------------
// Prepare for resumption of normal mode when
// the user stops dragging the table
// -----------------------------------------
- (void)prepareForQueueSelectionModeToEnd
{
    [UIView animateWithDuration:0.0 animations:^{self.navigationController.navigationBar.alpha = 1.0;}];
    [_tableView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0.0, 0.0, 0.0)];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [_tableView setTransform:CGAffineTransformMakeTranslation(0.0, 0.0)];
    _tableView.showsVerticalScrollIndicator = YES;
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
    _hasTimelineAnimated = NO;
    self.isTimelineExpanded = YES;
    self.selectedIndexPath = indexPath;
    self.tableView.scrollEnabled = NO;
    NSIndexPath *timelineIndexPath = [self timelineIndexPath];
    [self rotateRightNavButtonToClose];
    [self.tableView insertRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadData];
    [self slideTimelineDownWithAnimation:YES];
//    [self performSelector:@selector(slideTimeline) withObject:nil afterDelay:0.3];
//    [self performSelector:@selector(scrollCellAtIndexPathToTop:) withObject:_selectedIndexPath afterDelay:0.25];
//    [self scrollCellAtIndexPathToTop:timelineIndexPath];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [self.addButton setEnabled:NO];
    
    // Post a notification to all of the cells that timeline is expanded
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TimelineDidExpand"
     object:self];
}

- (void)hideTimelineWithContactReposition:(BOOL)reposition
{
    // Contract the cell to hide the timeline
    self.isTimelineExpanded = NO;
    [self rotateRightNavButtonToAdd];
    [self.timeline hideToolbelt];
    NSIndexPath *timelineIndexPath = [self timelineIndexPath];
    [self slideTimelineUpWithAnimation:YES completion:^{
    
//        [self.tableView deleteRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadData];
        if (reposition)
            [self repositionSelectedContact];
        self.tableView.scrollEnabled = YES;
        [self.addButton setEnabled:YES];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TimelineDidContract"
         object:self];
    
    }];
//    [self performSelector:@selector(slideTimeline) withObject:nil afterDelay:0.4];
//    [self.tableView reloadData];
//    [NSObject performBlock:^{
//        [self.tableView deleteRowsAtIndexPaths:@[timelineIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        if (reposition)
//            [self repositionSelectedContact];
//    }
//                afterDelay:0.3];
//    [self.timeline.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4];
    
    
    // Post a notification to all of the cells that timeline is expanded
    ;
}

- (void)scrollCellAtIndexPathToTop:(NSIndexPath *)indexPath
{
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    CGFloat offset = (indexPath.row-1) * contactRowHeight - 64 /* iOS7 status bar + nav bar */;
    [self.tableView setContentOffset:CGPointMake(0, offset) animated:YES];
}

- (void)slideTimelineDownWithAnimation:(BOOL)animated
{    
    CGFloat duration = animated ? 0.3 : 0.0;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self timelineIndexPath]];
    CGRect cellFrame = cell.frame;
    cellFrame.size.height = [self fullTimelineHeight];
    
//    CGRect frame = self.timeline.view.frame;
//    frame.origin.y = frame.origin.y + frame.size.height;
    
    CGRect shadowFrame = self.timeline.view.bounds;
    shadowFrame.size.height = [self fullTimelineHeight];
    
    // Change the table view's bounds so that the selected cell is
    // scrolled to the top. We do this instead of just setting the scroll position
    // or contentOffset because we want it to animate while the cells are sliding down
    // beneath it.
    _contractedBounds = _tableView.bounds;
    _expandedBounds = _contractedBounds;
    _expandedBounds.origin.y = _selectedIndexPath.row * contactRowHeight - self.navigationController.navigationBar.frame.size.height;

    [UIView animateWithDuration:duration
                     animations:^{
//                         self.timeline.view.frame = frame;
                         [cell setFrame:cellFrame];
                         [self.timeline.innerShadowView setFrame:shadowFrame];
                         [_tableView setBounds:_expandedBounds];
                         
                         // Move all the other cells down
                         for (int i = [self timelineIndexPath].row + 1; i <= [self.contactsArray count]; i++)
                         {
                             UITableViewCell *otherCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                             CGRect otherCellFrame = otherCell.frame;
                             otherCellFrame.origin.y += self.tableView.frame.size.height - contactRowHeight;
                             [otherCell setFrame:otherCellFrame];
                         }
                     } completion:^(BOOL finished){
                         _hasTimelineAnimated = YES;
                     }];
}

- (void)slideTimelineUpWithAnimation:(BOOL)animated completion:(void (^)(void))block
{
    CGFloat duration = animated ? 0.3 : 0.0;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self timelineIndexPath]];
    CGRect cellFrame = cell.frame;
    cellFrame.size.height = 0.0;
    
    CGRect shadowFrame = self.timeline.innerShadowView.frame;
    shadowFrame.size.height = 0.0;
    
//    CGRect frame = self.timeline.view.frame;
//    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:duration
                     animations:^{
                         [cell setFrame:cellFrame];
                         [self.timeline.innerShadowView setFrame:shadowFrame];
                         [_tableView setBounds:_contractedBounds];
                         
                         // Move all the other cells up
                         for (int i= [self timelineIndexPath].row + 1; i <= [self.contactsArray count]; i++)
                         {
                             UITableViewCell *otherCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                             CGRect otherCellFrame = otherCell.frame;
                             otherCellFrame.origin.y -= self.tableView.frame.size.height - contactRowHeight;
                             [otherCell setFrame:otherCellFrame];
                         }
                     } completion:^(BOOL finished) {
                         block();
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

#pragma mark - Location Management Methods
- (void)locationManager:(LLLocationManager *)locationManger didFinishGeocodingLocation:(NSDictionary *)location
{
    Location *newLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                                              inManagedObjectContext:_managedObjectContext];
    [newLocation populateWithGoogleReverseGeocodeResult:location];
    
    // Post a notification to all of the cells that the location has changed
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"DefaultLocationDidChange"
     object:newLocation];
    
    _defaultMeeting.location = newLocation;
}

# pragma mark - View Management Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Don't inset scroll view content - iOS7
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    
    // A a gesture recognizer to the navigation bar to let the user pull to switch queues using its area
    UIPanGestureRecognizer *navBarGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    navBarGesture.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:navBarGesture];
    
    self.view.backgroundColor = [UIColor clearColor];
	
    // Create a table view to hold the contacts
    LLPullNavigationTableView *tableView = [[LLPullNavigationTableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y/* + self.navigationController.navigationBar.frame.size.height*/,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height /*+ self.navigationController.navigationBar.frame.size.height*/ - [UIApplication sharedApplication].statusBarFrame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
//    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = contactRowHeight;
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
    
    // Set up the default meeting
    _defaultMeeting = (Meeting *)[NSEntityDescription insertNewObjectForEntityForName:@"Meeting"
                                                       inManagedObjectContext:_managedObjectContext];
    _defaultMeeting.date = [NSDate date];
    
    // Find the current location for the default meeting
    _locationManager = [[LLLocationManager alloc] initWithDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    _locationManager.delegate = self;
    [_locationManager startStandardUpdates];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Scroll back to the selected row if timeline is expanded
    // to counter an iOS7 issue where the scroll view's content offset
    // is adjusted when a new view is pushed on top of it and no one knows why
    if (_isTimelineExpanded)
    {
        [_tableView setBounds:_expandedBounds];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _pullController = (LLPullNavigationController *)[[self parentViewController] parentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
