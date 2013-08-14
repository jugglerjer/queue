//
//  TimelineViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/20/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "TimelineViewController.h"
#import "QueueViewController.h"
#import "QueueBarButtonItem.h"
#import "MeetingCell.h"  
#import "Contact.h"
#import "Meeting.h"
#import "Location.h"
#import "LLPullNavigationTableView.h"
#import "LLSwipeyCell.h"

#define kDateRow    0
#define kNoteRow    1

#define TIMELINE_MARGIN_LEFT    36
#define TIMELINE_WIDTH          2

#define BUTTON_MARGIN_RIGHT     11
#define BUTTON_MARGIN_BOTTOM    11
#define BUTTON_HEIGHT           44
#define BUTTON_WIDTH            44

#define TOOLBELT_HEIGHT         56
#define TOOLBELT_BUMP_DISTANCE  10

@interface TimelineViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSMutableArray * meetingsArray;
@property (strong, nonatomic) UIButton *arrowButton;
@property (strong, nonatomic) UIImageView *toolBelt;
@property (strong, nonatomic) NSMutableDictionary *mapDataDictionary;

@end

@implementation TimelineViewController

static NSString const *googleStaticMapURL = @"https://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDJk6VmHmcNveBQjDV91rJ3U4ExV0b4vIc&size=320x100&scale=2&sensor=true&zoom=15&visual_refresh=true";

- (id)initWithContact:(Contact *)contact
{
    if (self = [super init])
    {
        self.contact = contact;
        self.meetingsArray = [NSMutableArray arrayWithArray:[contact sortedMeetings]];
        self.mapDataDictionary = [NSMutableDictionary dictionaryWithCapacity:[self.meetingsArray count]];
    }
    return self;
}

// ------------------------------
// Save the updated contact data
// ------------------------------
- (void)save
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
}

- (void)addMeeting
{
    AddMeetingViewController *addMeetingController = [[AddMeetingViewController alloc] init];
    addMeetingController.managedObjectContext = self.managedObjectContext;
    addMeetingController.contact = self.contact;
    addMeetingController.delegate = self;
    addMeetingController.editMeetingType = QueueEditMeetingTypeAdd;
    UINavigationController *navContoller = [[UINavigationController alloc] initWithRootViewController:addMeetingController];
    [self.queueViewController.navigationController presentViewController:navContoller animated:YES completion:nil];
}

- (void)snoozeContact
{
    // Create a new meeting of type snooze
    Meeting *newMeeting = (Meeting *)[NSEntityDescription insertNewObjectForEntityForName:@"Meeting"
                                                                   inManagedObjectContext:_managedObjectContext];
    newMeeting.date = [NSDate date];
    newMeeting.note = @"Snoozed";
    newMeeting.method = @"snooze";
    
    [self.contact addMeetingsObject:newMeeting];
    [self addMeeting:newMeeting forContact:self.contact];
    [self save];
}

- (void)showSettings
{
    AddContactViewController *addContactController = [[AddContactViewController alloc] init];
    addContactController.managedObjectContext = self.managedObjectContext;
    addContactController.contact = self.contact;
    addContactController.delegate = self;
    addContactController.editContactType = QueueEditContactTypeUpdate;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addContactController];
    [self.queueViewController.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)contactContact
{
    
}

- (void)deleteContact
{
    if ([_delegate respondsToSelector:@selector(timelineViewController:shouldDeleteContact:)])
    {
        [_delegate timelineViewController:self shouldDeleteContact:self.contact];
    }
}

// -------------------------------------------------------------
// Animate the display of the toolbelt when the arrow
// button is pressed.
// -------------------------------------------------------------
- (void)showToolbelt
{    
    // Animate the toolbelt into position    
//    CGFloat totalDistance = self.view.frame.size.width - (BUTTON_MARGIN_RIGHT * 2) + (TOOLBELT_BUMP_DISTANCE * 2);
//    CGFloat initialDistancePortion = (self.view.frame.size.width - (BUTTON_MARGIN_RIGHT * 2) + TOOLBELT_BUMP_DISTANCE) / totalDistance;
//    CGFloat bumpDistancePortion = TOOLBELT_BUMP_DISTANCE / totalDistance;
//    
//    CGFloat totalDuration = 0.2;
    CGFloat initialDuration = /*initialDistancePortion * totalDuration*/0.2;
    CGFloat bumpDuration = /*bumpDistancePortion * totalDuration*/0.1;
    [UIView animateWithDuration:initialDuration
                     animations:^{
                         
                         // Expand the toolbelt
                         CGRect newFrame = self.toolBelt.frame;
                         newFrame.origin.x = BUTTON_MARGIN_RIGHT - TOOLBELT_BUMP_DISTANCE;
                         newFrame.size.width = self.view.frame.size.width - (BUTTON_MARGIN_RIGHT * 2) + TOOLBELT_BUMP_DISTANCE;
                         self.toolBelt.frame = newFrame;
                         
                         // Rotate the expand button
                         CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                         self.arrowButton.transform = transform;
                         
                         self.arrowButton.alpha = 0;
                         self.toolBelt.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:bumpDuration
                                          animations:^{
                                              CGRect newFrame = self.toolBelt.frame;
                                              newFrame.origin.x = BUTTON_MARGIN_RIGHT;
                                              newFrame.size.width = self.view.frame.size.width - (BUTTON_MARGIN_RIGHT * 2);
                                              self.toolBelt.frame = newFrame;
                                          }
                                          completion:nil];
                     }
     ];
    
    // Animate the buttons on the toolbelt
    
}

- (void)hideToolbelt
{
    CGFloat initialDuration = /*initialDistancePortion * totalDuration*/0.2;
//    CGFloat bumpDuration = /*bumpDistancePortion * totalDuration*/0.1;
    [UIView animateWithDuration:initialDuration
                     animations:^{
                         
                         // Contract the toolbelt
                         CGRect newFrame = self.toolBelt.frame;
                         newFrame.origin.x = self.view.frame.size.width - BUTTON_WIDTH - BUTTON_MARGIN_RIGHT;
                         newFrame.size.width = BUTTON_WIDTH;
                         self.toolBelt.frame = newFrame;

                         
                         // Rotate the expand button
                         CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                         self.arrowButton.transform = transform;
                         
                         self.arrowButton.alpha = 1;
                         self.toolBelt.alpha = 0;
                         
                     }
                     completion:nil];

}


// -------------------------------------------------------------
// Animate the addition of a meeting
// after a meeting is created
// -------------------------------------------------------------
- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController
                   didAddMeeting:(Meeting *)meeting
                      forContact:(Contact *)contact;
{
    [self addMeeting:meeting forContact:contact];
}

- (void)addMeeting:(Meeting *)meeting forContact:(Contact *)contact
{
    // Find the section index of the new meeting
    [self updateMeetingsArrayWithTableReload:NO];
    NSInteger row = [self.meetingsArray indexOfObject:meeting];
    
    // Animate the position change
    [self addNewMeeting:meeting withRow:row animated:YES];
    
    // Update the contact's queue cell
    if ([self.delegate respondsToSelector:@selector(timelineViewController:didUpdateContact:withMeeting:)]) {
        [self.delegate timelineViewController:self didUpdateContact:contact withMeeting:meeting];
    }
}

- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController
                didUpdateMeeting:(Meeting *)meeting
                      forContact:(Contact *)contact
{
    [self updateMeeting:meeting forContact:contact];
}

- (void)updateMeeting:(Meeting *)meeting forContact:(Contact *)contact
{
    // Get the meeting's current queue position
    NSInteger oldRow = [self.meetingsArray indexOfObject:meeting];
    
    // Update the meeting array
    [self updateMeetingsArrayWithTableReload:NO];
    
    // Get the meeting's new position
    NSInteger newRow = [self.meetingsArray indexOfObject:meeting];
    
    // Animate the position change
    if (oldRow != newRow) {
        [self updateMeeting:meeting toNewRow:newRow fromOldRow:oldRow animated:YES];
    } else {
        [self updateMeeting:meeting toNewRow:newRow fromOldRow:oldRow animated:NO];
    }
    
    // Update the contact's queue cell
    if ([self.delegate respondsToSelector:@selector(timelineViewController:didUpdateContact:withMeeting:)]) {
        [self.delegate timelineViewController:self didUpdateContact:contact withMeeting:meeting];
    }
}

// -------------------------------------------------------------
// Change the content of a contact's cell when their settings
// are updated
// -------------------------------------------------------------
- (void)addContactViewController:(AddContactViewController *)addContactViewController didUpdateContact:(Contact *)contact
{
    // Update the contact's queue cell
    if ([self.delegate respondsToSelector:@selector(timelineViewController:didUpdateContact:withMeeting:)]) {
        [self.delegate timelineViewController:self didUpdateContact:contact withMeeting:nil];
    }
}

- (void)updateMeetingsArrayWithTableReload:(BOOL)shouldReload
{
    self.meetingsArray = [NSMutableArray arrayWithArray:[self.contact sortedMeetings]];
    if (shouldReload) [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - 44 - 72 /* Nav Bar Height & Contact Row Height */)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    UIView *timeline = [[UIView alloc] initWithFrame:CGRectMake(TIMELINE_MARGIN_LEFT, 0, TIMELINE_WIDTH, self.view.frame.size.height)];
    timeline.backgroundColor = [UIColor blackColor];
    timeline.alpha = 0.2;
    [self.view addSubview:timeline];
    
    
    // Add floating buttons
    CGFloat buttonTopMargin = self.view.frame.size.height - self.queueViewController.navigationController.navigationBar.frame.size.height - [self.queueViewController tableView:self.queueViewController.tableView heightForRowAtIndexPath:self.queueViewController.selectedIndexPath];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(self.view.frame.size.width - BUTTON_WIDTH - BUTTON_MARGIN_RIGHT,
                                 buttonTopMargin - BUTTON_HEIGHT - BUTTON_MARGIN_BOTTOM,
                                 BUTTON_WIDTH,
                                 BUTTON_HEIGHT);
    [addButton setImage:[UIImage imageNamed:@"expand-button.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(showToolbelt) forControlEvents:UIControlEventTouchUpInside];
    self.arrowButton = addButton;
    
    UIImage *toolbeltImage = [[UIImage imageNamed:@"expanded-button.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:21];
    UIImageView *toolbelt = [[UIImageView alloc] initWithImage:toolbeltImage];
    CGRect frame = self.arrowButton.frame;
    frame.size.height = TOOLBELT_HEIGHT;
    frame.origin.y = self.arrowButton.frame.origin.y - (TOOLBELT_HEIGHT - BUTTON_HEIGHT) / 2;
    toolbelt.frame = frame;
    toolbelt.userInteractionEnabled = YES;
    self.toolBelt = toolbelt;
    self.toolBelt.alpha = 0;
    
    // Add toolbelt buttons
    NSArray *buttonsArray = @[@"delete-button.png", @"email-button.png", @"settings-button.png", @"snooze-button.png", @"add-meeting-button.png", @"contract-button.png"];
    NSArray *buttonSelectorsArray = @[@"deleteContact", @"contactContact", @"showSettings", @"snoozeContact", @"addMeeting", @"hideToolbelt"];
    CGRect buttonFrame = CGRectMake(0, (TOOLBELT_HEIGHT - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGFloat space = ((self.view.frame.size.width - (BUTTON_MARGIN_RIGHT * 2)) - ([buttonsArray count] * BUTTON_WIDTH)) / ([buttonsArray count] - 1);
    UIButton *toolbeltButton;
    for (int i = 0; i < [buttonsArray count]; i++)
    {
        buttonFrame.origin.x = i * BUTTON_WIDTH + i * space;
        toolbeltButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toolbeltButton.frame = buttonFrame;
        [toolbeltButton setImage:[UIImage imageNamed:[buttonsArray objectAtIndex:i]] forState:UIControlStateNormal];
        toolbeltButton.contentMode = UIViewContentModeCenter;
        [toolbeltButton addTarget:self action:NSSelectorFromString([buttonSelectorsArray objectAtIndex:i]) forControlEvents:UIControlEventTouchUpInside];
        toolbeltButton.showsTouchWhenHighlighted = YES;
        
        if (i == 1)
            [toolbeltButton setEnabled:NO];
        
        [self.toolBelt addSubview:toolbeltButton];
    }
    
//    UIButton *contractButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    contractButton.frame = CGRectMake(self.toolBelt.frame.size.width - BUTTON_WIDTH,
//                                      (TOOLBELT_HEIGHT - BUTTON_HEIGHT)/2,
//                                      self.arrowButton.frame.size.width,
//                                      self.arrowButton.frame.size.height);
//    [contractButton setImage:[UIImage imageNamed:@"contract-button.png"] forState:UIControlStateNormal];
//    contractButton.contentMode = UIViewContentModeCenter;
//    [self.toolBelt addSubview:contractButton];
    
    [self.view addSubview:self.toolBelt];
    [self.view addSubview:self.arrowButton];
    
    
    UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    _innerShadowView = [[UIImageView alloc] initWithImage:innerShadow];
    CGRect shadowFrame = self.tableView.bounds;
    shadowFrame.size.height = 0.0f;
    _innerShadowView.frame = shadowFrame;
    [self.view addSubview:_innerShadowView];
    
    // Add the add meeting button to the right side of the nav bar
//    QueueBarButtonItem *addMeetingButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeAdd target:self action:@selector(addMeeting)];
//    self.navigationItem.rightBarButtonItem = addMeetingButton;
//    
//    QueueBarButtonItem *backButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeBack target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = backButton;
    
    // Show the toolbelt if the user has no meetings
    if ([self.meetingsArray count] == 0)
        [self performSelector:@selector(showToolbelt) withObject:nil afterDelay:0.25];

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.meetingsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellHeightString = [[NSNumber numberWithFloat:[self tableView:tableView heightForRowAtIndexPath:indexPath]] stringValue];
    NSString *MeetingCellIdentifier = [NSString stringWithFormat:@"MeetingCell%@", cellHeightString];
    MeetingCell *cell;
    
    // Make sure we're not dequeueing a cell that's still visible
//    if ([self.meetingsArray count] > [[tableView visibleCells] count] + 2)
        cell = [tableView dequeueReusableCellWithIdentifier:MeetingCellIdentifier];
//    else
//        cell = nil;
    
    if (cell == nil)
    {
        cell = [[MeetingCell alloc] initWithReuseIdentifier:MeetingCellIdentifier];
    }
    
    Meeting *meeting = [self.meetingsArray objectAtIndex:indexPath.row];
    [cell configureWithMeeting:meeting];
    
    // If the meeting has a location,
    // start downloading the map
    // or show a map that's already been downloaded
    if (meeting.location)
    {
        if ([self.mapDataDictionary objectForKey:[NSNumber numberWithInt:indexPath.row]])
        {
            cell.mapView.alpha = 0;
            cell.mapView.image = [UIImage imageWithData:[self.mapDataDictionary objectForKey:[NSNumber numberWithInt:indexPath.row]]];
            [UIView animateWithDuration:0.4 animations:^{cell.mapView.alpha = 1;}];
        }
        else
        {
            LLDataDownloader *mapDownloader = [[LLDataDownloader alloc] init];
            mapDownloader.delegate = self;
            mapDownloader.identifier = indexPath.row;
            NSString *url = [NSString stringWithFormat:@"%@&markers=color:red|%f,%f", googleStaticMapURL, [meeting.location.latitude doubleValue], [meeting.location.longitude doubleValue]];
            [mapDownloader getDataWithURL:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    cell.delegate = self;
    return cell;
}

// -------------------------------------
// Adds a Google Static Map to the cell
// once the map data has downloaded
// -------------------------------------
- (void)dataHasFinishedDownloadingForDownloader:(LLDataDownloader *)downloader withResult:(BOOL)result andData:(NSData *)data
{
    if (result)
    {
        UIImage *imageTemp = [UIImage imageWithData:data];
        if (imageTemp != nil)
        {
            [self.mapDataDictionary setObject:data forKey:[NSNumber numberWithInt:downloader.identifier]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:downloader.identifier inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return TOOLBELT_HEIGHT + BUTTON_MARGIN_BOTTOM;
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
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, TOOLBELT_HEIGHT + BUTTON_MARGIN_BOTTOM, tableView.frame.size.width, TOOLBELT_HEIGHT + BUTTON_MARGIN_BOTTOM)];
    footer.backgroundColor = [UIColor clearColor];
    
    UIView *tableBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.5)];
    tableBottomLine.backgroundColor = [UIColor whiteColor];
    tableBottomLine.alpha = 0.2;
    [footer addSubview:tableBottomLine];
    
    return footer;
}

#define MARGIN_TOP      20
#define MARGIN_BOTTOM   20
#define MARGIN_LEFT     63
#define MARGIN_RIGHT    30

#define NOTE_HEIGHT     20
#define DATE_HEIGHT     18

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[self.meetingsArray objectAtIndex:indexPath.row] note];
    CGSize constraint = CGSizeMake(self.view.frame.size.width - MARGIN_LEFT - MARGIN_RIGHT, 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0] constrainedToSize:constraint];
    
    int mapHeight = 0;
    if ([[self.meetingsArray objectAtIndex:indexPath.row] location])
        mapHeight = 100.5;
    
    return size.height + MARGIN_TOP + MARGIN_BOTTOM + DATE_HEIGHT + mapHeight + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Meeting *meeting = [self.meetingsArray objectAtIndex:indexPath.row];
    AddMeetingViewController *addMeetingController = [[AddMeetingViewController alloc] initWithMeeting:meeting];
    addMeetingController.managedObjectContext = self.managedObjectContext;
    addMeetingController.contact = self.contact;
    addMeetingController.delegate = self;
    addMeetingController.editMeetingType = QueueEditMeetingTypeUpdate;
    UINavigationController *navContoller = [[UINavigationController alloc] initWithRootViewController:addMeetingController];
    [self.queueViewController.navigationController presentViewController:navContoller animated:YES completion:nil];
}

- (void)addNewMeeting:(Meeting *)meeting withRow:(NSUInteger)row animated:(BOOL)animated
{    
    if (animated) {
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    } else {
        [self.tableView reloadData];
    }
}

- (void)updateMeeting:(Meeting *)meeting toNewRow:(NSUInteger)newRow fromOldRow:(NSUInteger)oldRow animated:(BOOL)animated
{
    if (animated) {
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    } else {
        [self.tableView reloadData];
    }
}

- (void)deleteMeeting:(Meeting *)meeting atRow:(NSUInteger)row animated:(BOOL)animated
{    
    if (animated)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
    else
    {
        [self.tableView reloadData];
    }
}

# pragma mark swipey cell delegate methods

- (void)swipeyCellDidBeginDragging:(LLSwipeyCell *)cell
{
    [self.tableView setScrollEnabled:NO];
}

- (void)swipeyCellDidEndDragging:(LLSwipeyCell *)cell
{
    [self.tableView setScrollEnabled:YES];
}

- (void)meetingCell:(MeetingCell *)meetingCell didDeleteMeeting:(Meeting *)meeting
{
    [self.contact removeMeetingsObject:meeting];
    NSUInteger row = [self.meetingsArray indexOfObject:meeting];
    [self updateMeetingsArrayWithTableReload:NO];
    [self deleteMeeting:meeting atRow:row animated:YES];
    [self save];
    
    // Update the contact's queue cell
    if ([self.delegate respondsToSelector:@selector(timelineViewController:didUpdateContact:withMeeting:)])
        [self.delegate timelineViewController:self didUpdateContact:self.contact withMeeting:meeting];
}

@end
