//
//  AddMeetingViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/19/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "AddMeetingViewController.h"
#import "QueueBarButtonItem.h"
#import "LocationChooserViewController.h"
#import "Meeting.h"
#import "Contact.h"

#define kDateCellRow    0
#define kNoteCellRow    1

@interface AddMeetingViewController ()

@property (strong, nonatomic) Meeting * meeting;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UITextView * textView;
@property (strong, nonatomic) UILabel * dateLabel;
@property BOOL isKeyboardVisible;
@property BOOL isDatePickerVisible;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation AddMeetingViewController

static CGFloat keyboardHeight = 216;

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

#define DATE_TEXT_MARGIN_LEFT       48
#define DATE_TEXT_MARGIN_RIGHT      48
#define DATE_TEXT_MARGIN_TOP        20
#define DATE_TEXT_MARGIN_BOTTOM     20
#define DATE_TEXT_HEIGHT            15

#define NOTE_TEXT_MARGIN_LEFT       48
#define NOTE_TEXT_MARGIN_RIGHT      48
#define NOTE_TEXT_MARGIN_TOP        20
#define NOTE_TEXT_MARGIN_BOTTOM     20
#define NOTE_TEXT_HEIGHT            15

#define NOTE_TEXT_INSET_LEFT        40.0f
#define NOTE_TEXT_INSET_RIGHT       -40.0f
#define NOTE_TEXT_INSET_TOP         9.0f
#define NOTE_TEXT_INSET_BOTTOM      9.0f

#define PLACE_TEXT_MARGIN_LEFT       48
#define PLACE_TEXT_MARGIN_RIGHT      48
#define PLACE_TEXT_MARGIN_TOP        20
#define PLACE_TEXT_MARGIN_BOTTOM     20
#define PLACE_TEXT_HEIGHT            15

#define ICON_HEIGHT                  14
#define ICON_WIDTH                   13

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light-background.png"]];
    
   
    
    // Add the save and cancel buttons to the nav bar    
    QueueBarButtonItem *cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(cancel)];
    QueueBarButtonItem *addMeetingButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeDone target:self action:@selector(saveMeeting)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = addMeetingButton;
    
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
//                                                                           self.view.bounds.origin.y,
//                                                                           self.view.bounds.size.width,
//                                                                           self.view.bounds.size.height)
//                                                          style:UITableViewStylePlain];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    self.tableView = tableView;
//    [self.view addSubview:self.tableView];
    
    UIControl *dateViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                         self.view.bounds.origin.y,
                                                                         self.view.bounds.size.width,
                                                                         DATE_TEXT_HEIGHT + DATE_TEXT_MARGIN_TOP + DATE_TEXT_MARGIN_BOTTOM)];
    [dateViewContainer addTarget:self action:@selector(shouldEditDateField) forControlEvents:UIControlEventTouchUpInside];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateViewContainer.bounds.origin.x + DATE_TEXT_MARGIN_LEFT,
                                                                   dateViewContainer.bounds.origin.y + DATE_TEXT_MARGIN_TOP,
                                                                   dateViewContainer.bounds.size.width - DATE_TEXT_MARGIN_LEFT - DATE_TEXT_MARGIN_RIGHT,
                                                                   DATE_TEXT_HEIGHT)];
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dateLabel.textColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1];
    dateLabel.text = [self stringForMeetingDate:self.meeting.date];
    self.dateLabel = dateLabel;
    UIImageView *calendarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_full.png"]];
    calendarIcon.frame = CGRectMake((DATE_TEXT_MARGIN_LEFT - ICON_WIDTH)/2,
                                    ((DATE_TEXT_MARGIN_TOP + DATE_TEXT_HEIGHT + DATE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
                                    ICON_WIDTH,
                                    ICON_HEIGHT);
    [dateViewContainer addSubview:calendarIcon];
    [dateViewContainer addSubview:self.dateLabel];
    [self.view addSubview:dateViewContainer];
    UIView *dividerLine = [[UIView alloc] initWithFrame:CGRectMake(dateViewContainer.bounds.origin.x,
                                                                   dateViewContainer.bounds.size.height - 0.5,
                                                                   dateViewContainer.bounds.size.width,
                                                                   0.5)];
    dividerLine.backgroundColor = [UIColor blackColor];
    dividerLine.alpha = 0.2;
    [dateViewContainer addSubview:dividerLine];
    
    UIControl *noteViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                         self.view.bounds.origin.y + dateViewContainer.bounds.size.height,
                                                                         self.view.bounds.size.width,
                                                                         self.view.bounds.size.height - keyboardHeight - self.navigationController.navigationBar.frame.size.height - PLACE_TEXT_HEIGHT - PLACE_TEXT_MARGIN_TOP - PLACE_TEXT_MARGIN_BOTTOM - dateViewContainer.bounds.size.height)];
    noteViewContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light-background.png"]];
    [noteViewContainer addTarget:self action:@selector(shouldEditNoteField) forControlEvents:UIControlEventTouchUpInside];
//    UITextView *noteView = [[UITextView alloc] initWithFrame:CGRectMake(noteViewContainer.bounds.origin.x + NOTE_TEXT_MARGIN_LEFT,
//                                                                        noteViewContainer.bounds.origin.y + NOTE_TEXT_MARGIN_TOP,
//                                                                        noteViewContainer.bounds.size.width - NOTE_TEXT_MARGIN_LEFT - NOTE_TEXT_MARGIN_RIGHT,
//                                                                        noteViewContainer.bounds.size.height - NOTE_TEXT_MARGIN_TOP - NOTE_TEXT_MARGIN_BOTTOM)];
    CGRect noteViewFrame = noteViewContainer.bounds;
    noteViewFrame.size.width = noteViewFrame.size.width - NOTE_TEXT_MARGIN_RIGHT;
    noteViewFrame.size.height = noteViewFrame.size.height - NOTE_TEXT_MARGIN_BOTTOM;
    noteViewFrame.origin.x = NOTE_TEXT_INSET_LEFT;
    UITextView *noteView = [[UITextView alloc] initWithFrame:noteViewFrame];
    noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    noteView.textColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1];
    noteView.contentInset = UIEdgeInsetsMake(NOTE_TEXT_INSET_TOP, 0, NOTE_TEXT_INSET_BOTTOM, NOTE_TEXT_INSET_RIGHT);
    noteView.backgroundColor = [UIColor clearColor];
    noteView.text = self.meeting.note;
    UIImageView *noteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notepad.png"]];
    noteIcon.frame = CGRectMake((NOTE_TEXT_MARGIN_LEFT - ICON_WIDTH)/2,
                                    ((NOTE_TEXT_MARGIN_TOP + NOTE_TEXT_HEIGHT + NOTE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
                                    ICON_WIDTH,
                                    ICON_HEIGHT);
    [noteViewContainer addSubview:noteIcon];
    noteView.text = self.meeting.note;
    noteView.delegate = self;
    self.textView = noteView;
    [noteViewContainer addSubview:self.textView];
    [self.view addSubview:noteViewContainer];
    
    CGRect locationFrame = self.view.bounds;
    locationFrame.origin.y = locationFrame.origin.y + dateViewContainer.frame.size.height + noteViewContainer.frame.size.height;
    LocationChooserViewController *locationChooser = [[LocationChooserViewController alloc] init];
    locationChooser.view.frame = locationFrame;
    [self.view addSubview:locationChooser.view];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                              self.view.bounds.size.height - keyboardHeight - self.navigationController.navigationBar.frame.size.height,
                                                                              self.view.bounds.size.width,
                                                                              keyboardHeight)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate date];
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

#pragma mark - Date Picker & Keyboard Methods

- (NSString *)stringForMeetingDate:(NSDate *)meetingDate
{
    NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
    [meetingDateFormatter setDateFormat:@"EEEE, MMMM d, y"];
    return [meetingDateFormatter stringFromDate:meetingDate];
}

- (void)shouldEditDateField
{
    if ([self.textView isFirstResponder])
        [self.textView resignFirstResponder];
    
    [self showDatePickerAnimated:YES completion:nil];
}

- (void)shouldEditNoteField
{
    [self hideDatePickerAnimated:YES completion:^{[self.textView becomeFirstResponder];}];
}

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
    self.dateLabel.text = [self stringForMeetingDate:self.meeting.date];
}

@end
