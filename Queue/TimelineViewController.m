//
//  TimelineViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/20/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "TimelineViewController.h"
#import "AddMeetingViewController.h"
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
    [self.navigationController presentViewController:navContoller animated:YES completion:nil];
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
    NSInteger section = [self.meetingsArray indexOfObject:meeting];
    
    // Animate the position change
    [self addNewMeeting:meeting withSection:section animated:YES];
}

- (void)addMeetingViewController:(AddMeetingViewController *)addMeetingViewController
                didUpdateMeeting:(Meeting *)meeting
                      forContact:(Contact *)contact
{
    // Get the meeting's current queue position
    NSInteger oldSection = [self.meetingsArray indexOfObject:meeting];
    
    // Update the meeting array
    [self updateMeetingsArrayWithTableReload:NO];
    
    // Get the meeting's new position
    NSInteger newSection = [self.meetingsArray indexOfObject:meeting];
    
    // Animate the position change
    if (oldSection != newSection) {
        [self updateMeeting:meeting toNewSection:newSection fromOldSection:oldSection animated:YES];
    } else {
        [self updateMeeting:meeting toNewSection:newSection fromOldSection:oldSection animated:NO];
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
                                                                           self.view.bounds.size.height)
                                                          style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    // Add the add meeting button to the right side of the nav bar
    UIBarButtonItem *addMeetingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                      target:self
                                                                                      action:@selector(addMeeting)];
    self.navigationItem.rightBarButtonItem = addMeetingButton;

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
    return [self.meetingsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MeetingCellIdentifier = @"MeetingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MeetingCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MeetingCellIdentifier];
    }
    
    Meeting *meeting = [self.meetingsArray objectAtIndex:indexPath.section];
    
    if (indexPath.row == kDateRow)
    {
        NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
        [meetingDateFormatter setDateFormat:@"MMMM d, y"];
        cell.textLabel.text = [meetingDateFormatter stringFromDate:meeting.date];
    }
    
    else if (indexPath.row == kNoteRow)
    {
        cell.textLabel.text = meeting.note;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Meeting *meeting = [self.meetingsArray objectAtIndex:indexPath.section];
    AddMeetingViewController *addMeetingController = [[AddMeetingViewController alloc] initWithMeeting:meeting];
    addMeetingController.managedObjectContext = self.managedObjectContext;
    addMeetingController.contact = self.contact;
    addMeetingController.delegate = self;
    addMeetingController.editMeetingType = QueueEditMeetingTypeUpdate;
    UINavigationController *navContoller = [[UINavigationController alloc] initWithRootViewController:addMeetingController];
    [self.navigationController presentViewController:navContoller animated:YES completion:nil];
}

- (void)addNewMeeting:(Meeting *)meeting withSection:(NSUInteger)section animated:(BOOL)animated
{    
    if (animated) {
        
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    } else {
        [self.tableView reloadData];
    }
}

- (void)updateMeeting:(Meeting *)meeting toNewSection:(NSUInteger)newSection fromOldSection:(NSUInteger)oldSection animated:(BOOL)animated
{
    if (animated) {
        
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newSection] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:oldSection] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    } else {
        [self.tableView reloadData];
    }
}

@end
