//
//  TimelineViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/20/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "TimelineViewController.h"
#import "AddMeetingViewController.h"
#import "QueueViewController.h"
#import "QueueBarButtonItem.h"
#import "MeetingCell.h"  
#import "Contact.h"
#import "Meeting.h"

#define kDateRow    0
#define kNoteRow    1

@interface TimelineViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSMutableArray * meetingsArray;

@end

@implementation TimelineViewController

- (id)initWithContact:(Contact *)contact
{
    if (self = [super init])
    {
        self.contact = contact;
        self.meetingsArray = [NSMutableArray arrayWithArray:[contact sortedMeetings]];
    }
    return self;
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

// -------------------------------------------------------------
// Animate the addition of a meeting
// after a meeting is created
// -------------------------------------------------------------
- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController
                   didAddMeeting:(Meeting *)meeting
                      forContact:(Contact *)contact;
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

- (void)updateMeetingsArrayWithTableReload:(BOOL)shouldReload
{
    self.meetingsArray = [NSMutableArray arrayWithArray:[self.contact sortedMeetings]];
    if (shouldReload) [self.tableView reloadData];
}

#define TIMELINE_MARGIN_LEFT    36
#define TIMELINE_WIDTH          2

#define BUTTON_MARGIN_RIGHT     11
#define BUTTON_MARGIN_BOTTOM    11
#define BUTTON_HEIGHT           44
#define BUTTON_WIDTH            44

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height)
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
    
    CGFloat buttonTopMargin = self.view.frame.size.height - self.queueViewController.navigationController.navigationBar.frame.size.height - [self.queueViewController tableView:self.queueViewController.tableView heightForRowAtIndexPath:self.queueViewController.selectedIndexPath];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(self.view.frame.size.width - BUTTON_WIDTH - BUTTON_MARGIN_RIGHT,
                                 buttonTopMargin - BUTTON_HEIGHT - BUTTON_MARGIN_BOTTOM,
                                 BUTTON_WIDTH,
                                 BUTTON_HEIGHT);
    [addButton setImage:[UIImage imageNamed:@"expand-button.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addMeeting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    
    UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    UIImageView *innerShadowView = [[UIImageView alloc] initWithImage:innerShadow];
    innerShadowView.frame = self.tableView.bounds;
    [self.view addSubview:innerShadowView];
    
    // Add the add meeting button to the right side of the nav bar
//    QueueBarButtonItem *addMeetingButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeAdd target:self action:@selector(addMeeting)];
//    self.navigationItem.rightBarButtonItem = addMeetingButton;
//    
//    QueueBarButtonItem *backButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeBack target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = backButton;

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
    static NSString *MeetingCellIdentifier = @"MeetingCell";
    MeetingCell *cell = [tableView dequeueReusableCellWithIdentifier:MeetingCellIdentifier];
    if (cell == nil)
    {
        cell = [[MeetingCell alloc] initWithReuseIdentifier:MeetingCellIdentifier];
    }
    
    Meeting *meeting = [self.meetingsArray objectAtIndex:indexPath.row];
    [cell configureWithMeeting:meeting];
    
    CGRect lineFrame = CGRectMake(0,0,cell.bounds.size.width, 0.5);
    
    lineFrame.origin.y = [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5;
    cell.bottomLine.frame = lineFrame;
    
    if (indexPath.row == 0)
    {
        lineFrame.origin.y = -0.5;
        cell.tableTopLine.frame = lineFrame;
    }
    
    if (indexPath.row == [self.meetingsArray count] - 1)
    {
        lineFrame.origin.y = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        cell.tableBottomLine.frame = lineFrame;
    }
    return cell;
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
    return size.height + MARGIN_TOP + MARGIN_BOTTOM + DATE_HEIGHT;
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

@end
