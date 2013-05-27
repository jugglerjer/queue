//
//  AddMeetingViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/19/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "AddMeetingViewController.h"
#import "QueueBarButtonItem.h"
#import "Meeting.h"
#import "Contact.h"

#define kDateCellRow    0
#define kNoteCellRow    1

@interface AddMeetingViewController ()

@property (strong, nonatomic) Meeting * meeting;
@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UITextView * textView;
@property BOOL isKeyboardVisible;
@property BOOL isDatePickerVisible;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation AddMeetingViewController

static CGFloat keyboardHeight = 216;
static CGFloat cellPadding = 10;
static CGFloat dateCellHeight = 44;

- (id)initWithMeeting:(Meeting *)meeting
{
    self = [super init];
    if (self) {
        self.meeting = meeting;
    }
    return self;
}

- (void)saveMeeting
{
    self.meeting.note = self.textView.text;
    [self.contact addMeetingsObject:self.meeting];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            if  (self.editMeetingType == QueueEditMeetingTypeAdd)
            {
                if ([_delegate respondsToSelector:@selector(addMeetingViewController:didAddMeeting:forContact:)])
                {
                    [_delegate addMeetingViewController:self didAddMeeting:self.meeting forContact:self.contact];
                }
            }
            else if (self.editMeetingType == QueueEditMeetingTypeUpdate)
            {
                if ([_delegate respondsToSelector:@selector(addMeetingViewController:didUpdateMeeting:forContact:)])
                {
                    [_delegate addMeetingViewController:self didUpdateMeeting:self.meeting forContact:self.contact];
                }
            }
            
        }];
    }
    
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Create Meeting Object
    if (self.meeting == nil) {
        Meeting *newMeeting = (Meeting *)[NSEntityDescription insertNewObjectForEntityForName:@"Meeting"
                                                                       inManagedObjectContext:_managedObjectContext];
        newMeeting.date = [NSDate date];
        newMeeting.note = @"";
        self.meeting = newMeeting;
        self.title = @"Add Meeting";
    } else {
        self.title = @"Edit Meeting";
    }
    
   
    
    // Add the save and cancel buttons to the nav bar    
    QueueBarButtonItem *cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(cancel)];
    QueueBarButtonItem *addMeetingButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeDone target:self action:@selector(saveMeeting)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = addMeetingButton;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           self.view.bounds.origin.y,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height)
                                                          style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                              self.view.bounds.size.height - keyboardHeight - self.navigationController.navigationBar.frame.size.height,
                                                                              self.view.bounds.size.width,
                                                                              keyboardHeight)];
    datePicker.date = self.meeting.date;
    [datePicker addTarget:self action:@selector(datePickerDateDidChange:) forControlEvents:UIControlEventValueChanged];
    self.datePicker = datePicker;
    [self.view addSubview:self.datePicker];
    
    self.isDatePickerVisible = YES;
    self.isKeyboardVisible = NO;
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddMeetingCellIdentifier = @"AddMeetingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddMeetingCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddMeetingCellIdentifier];
        
        if (indexPath.row == kNoteCellRow)
        {
            UITextView *noteView = [[UITextView alloc] initWithFrame:CGRectMake(cell.frame.origin.x  + cellPadding,
                                                                                cell.frame.origin.y + cellPadding,
                                                                                cell.frame.size.width - (2*cellPadding),
                                                                                [self heightForNoteCellRowInTableView:tableView] - (2*cellPadding))];
            noteView.backgroundColor = [UIColor clearColor];
            noteView.text = self.meeting.note;
            noteView.delegate = self;
            self.textView = noteView;
            [cell addSubview:self.textView];
        }
    }
    
    if (indexPath.row == kDateCellRow)
    {
        
        NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
        [meetingDateFormatter setDateFormat:@"MMMM d, y"];
        cell.textLabel.text = [NSString stringWithFormat:@"Date: %@", [meetingDateFormatter stringFromDate:self.meeting.date]];
    }
    else if (indexPath.row == kNoteCellRow)
    {
        self.textView.text = self.meeting.note;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kNoteCellRow)
    {
        return [self heightForNoteCellRowInTableView:tableView];
    }
    
    return dateCellHeight;
}

- (CGFloat)heightForNoteCellRowInTableView:(UITableView *)tableView
{
    return tableView.frame.size.height - dateCellHeight - keyboardHeight - self.navigationController.navigationBar.frame.size.height - (2*cellPadding);
}

#pragma mark - Note View Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.isDatePickerVisible == YES) {
        [self hideDatePickerAnimated:YES completion:^{[self.textView becomeFirstResponder];}];
        return NO;
    }
    else {
        return YES;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show or hide the date picker depending on whether the dateCellRow was selected
    if (indexPath.row == kDateCellRow)
    {
        if ([self.textView isFirstResponder])
            [self.textView resignFirstResponder];
        
        [self showDatePickerAnimated:YES completion:nil];
    }
    else {
        [self hideDatePickerAnimated:YES completion:nil];
    }
}

#pragma mark - Date Picker & Keyboard Methods

- (void)registerForKeyboardNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden)
                                                 name:UIKeyboardDidHideNotification object:nil];
}
- (void)keyboardWasShown
{
    self.isKeyboardVisible = YES;
}

- (void)keyboardWasHidden
{
    self.isKeyboardVisible = NO;
}

- (void)showDatePickerAnimated:(BOOL)animated completion:(void (^)())completionBlock;
{
    if (self.isDatePickerVisible == NO) {
        CGRect newFrame = CGRectMake(self.view.bounds.origin.x,
                                     self.view.bounds.size.height - keyboardHeight,
                                     self.view.bounds.size.width,
                                     keyboardHeight);
        float duration = animated ? 0.25f : 0.0f;
        float delay = self.isKeyboardVisible ? 0.25f : 0.0f;
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                         animations:^{self.datePicker.frame = newFrame;}
                         completion:^(BOOL finished){
                             [self setIsDatePickerVisible:YES];
                             if (completionBlock != nil)
                                 completionBlock();
                         }];
    }
}

- (void)hideDatePickerAnimated:(BOOL)animated completion:(void (^)())completionBlock;
{
    if (self.isDatePickerVisible == YES) {
        CGRect newFrame = CGRectMake(self.view.bounds.origin.x,
                                     self.view.bounds.size.height,
                                     self.view.bounds.size.width,
                                     keyboardHeight);
        float duration = animated ? 0.25f : 0.0f;
        float delay = 0.0f;
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                         animations:^{self.datePicker.frame = newFrame;}
                         completion:^(BOOL finished){
                             [self setIsDatePickerVisible:NO];
                             if (completionBlock != nil)
                                 completionBlock();
                         }];
    }
}

- (void)datePickerDateDidChange:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.meeting.date = datePicker.date;
    [self.tableView reloadData];
}

@end
