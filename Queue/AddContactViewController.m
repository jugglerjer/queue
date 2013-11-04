//
//  AddContactViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 6/5/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "AddContactViewController.h"
#import "QueueBarButtonItem.h"
#import "Contact.h"
#import "NSArray-SortUsingArray.h"
#import "ContactImageView.h"

//#define DUE_DATE_MARGIN_LEFT       48
//#define DUE_DATE_MARGIN_RIGHT      13
//#define DUE_DATE_MARGIN_TOP        20
//#define DUE_DATE_MARGIN_BOTTOM     20
//#define DUE_DATE_TEXT_HEIGHT       15

#define DUE_DATE_MARGIN_LEFT       48
#define DUE_DATE_MARGIN_RIGHT      48
#define DUE_DATE_MARGIN_TOP        14
#define DUE_DATE_MARGIN_BOTTOM     14
#define DUE_DATE_TEXT_HEIGHT            18
#define DUE_DATE_SUBTEXT_HEIGHT         15

#define INTERVAL_MARGIN_LEFT       48
#define INTERVAL_MARGIN_RIGHT      48
#define INTERVAL_MARGIN_TOP        20
#define INTERVAL_MARGIN_BOTTOM     20
#define INTERVAL_TEXT_HEIGHT       15

#define NOTE_TEXT_MARGIN_LEFT       48
#define NOTE_TEXT_MARGIN_RIGHT      48
#define NOTE_TEXT_MARGIN_TOP        20
#define NOTE_TEXT_MARGIN_BOTTOM     20
#define NOTE_TEXT_HEIGHT            15

#define NOTE_TEXT_INSET_LEFT        40.0f
#define NOTE_TEXT_INSET_RIGHT       -40.0f
#define NOTE_TEXT_INSET_TOP         9.0f
#define NOTE_TEXT_INSET_BOTTOM      9.0f

#define REMINDER_MARGIN_LEFT       48
#define REMINDER_MARGIN_RIGHT      48
#define REMINDER_MARGIN_TOP        20
#define REMINDER_MARGIN_BOTTOM     20
#define REMINDER_TEXT_HEIGHT       15

#define ICON_HEIGHT                  14
#define NOTE_ICON_WIDTH              13
#define INTERVAL_ICON_WIDTH          17.5

#define REMINDER_ICON_HEIGHT         16
#define REMINDER_ICON_WIDTH          17.5

#define REMINDER_BUTTON_ICON_HEIGHT     20
#define REMINDER_BUTTON_ICON_WIDTH      18

#define THUMBNAIL_HEIGHT             30
#define THUMBNAIL_WIDTH              30

#define kTypeComponent			0
#define kUnitComponent			1

#define kNumberOfReminderButtons       4
#define kNumberOfButtonRows            2
#define kNumberOfButtonColumns         2
#define kReminderDayOfButton           0
#define kReminderDayBeforeButton       1
#define kReminderWeekBeforeButton      2
#define kReminderWeekAfterButton       3

@interface AddContactViewController ()

@property (strong, nonatomic) UILabel *dueDateLabel;
@property (strong, nonatomic) UILabel *intervalLabel;
@property (strong, nonatomic) UITextView *noteTextView;
@property (strong, nonatomic) UILabel *reminderLabel;
@property (strong, nonatomic) UIImageView *reminderIcon;

@property (strong, nonatomic) UIDatePicker *dueDatePicker;
@property (strong, nonatomic) UIPickerView *intervalPicker;

@property (strong, nonatomic) NSDictionary *intervalOptions;
@property (strong, nonatomic) NSArray *timeUnit;
@property (strong, nonatomic) NSArray *timeType;

@property (strong, nonatomic) NSMutableArray *reminderArray;
@property (strong, nonatomic) NSNumber *originalMeetInterval;
@property (strong, nonatomic) NSNumber *originalHasReminderDayOf;
@property (strong, nonatomic) NSNumber *originalHasReminderDayBefore;
@property (strong, nonatomic) NSNumber *originalHasReminderWeekBefore;
@property (strong, nonatomic) NSNumber *originalHasReminderWeekAfter;

@property BOOL isDueDatePickerVisible;
@property BOOL isIntervalPickerVisible;
@property BOOL isKeyboardVisible;

@property (strong, nonatomic) NSArray *reminderEnabledButtonImages;
@property (strong, nonatomic) NSArray *reminderDisabledButtonImages;

@end

@implementation AddContactViewController

static CGFloat keyboardHeight = 216;

- (id)init
{
    if (self = [super init])
    {
        // Make sure that the content doesn't hide behind the nav bar in iOS7
        // This is appropriate because nothing on this page scrolls
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

// ------------------------------
// Save the updated settings
// and dismiss the view
// when the user taps the check
// ------------------------------
- (void)save
{
    self.contact.note = self.noteTextView.text;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    } else {
        // TODO - let the delegate know that we've updated the contact's settings
        [self dismissViewControllerAnimated:YES completion:^{
                if ([_delegate respondsToSelector:@selector(addContactViewController:didUpdateContact:)])
                    [_delegate addContactViewController:self didUpdateContact:self.contact];
            }];
    }
}

// ------------------------------
// Dismiss the view without saving
// when the user taps the x
// ------------------------------
- (void)close
{
    self.contact.meetInterval = self.originalMeetInterval;
    self.contact.hasReminderDayOf = self.originalHasReminderDayOf;
    self.contact.hasReminderDayBefore = self.originalHasReminderDayBefore;
    self.contact.hasReminderWeekBefore = self.originalHasReminderWeekBefore;
    self.contact.hasReminderWeekAfter = self.originalHasReminderWeekAfter;
    [self dismissViewControllerAnimated:YES completion:nil];
    if([_delegate respondsToSelector:@selector(addContactViewController:didDismissWithoutUpdatingContact:)])
        [_delegate addContactViewController:self didDismissWithoutUpdatingContact:self.contact];
}

// ------------------------------
// Slide away the view without saving
// when the user taps the back button
// ------------------------------
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    if([_delegate respondsToSelector:@selector(addContactViewController:didDismissWithoutUpdatingContact:)])
        [_delegate addContactViewController:self didDismissWithoutUpdatingContact:self.contact];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up any necessary temporary data
    self.originalMeetInterval = [self.contact.meetInterval copy];
    self.originalHasReminderDayOf = [self.contact.hasReminderDayOf copy];
    self.originalHasReminderDayBefore = [self.contact.hasReminderDayBefore copy];
    self.originalHasReminderWeekBefore = [self.contact.hasReminderWeekBefore copy];
    self.originalHasReminderWeekAfter = [self.contact.hasReminderWeekAfter copy];
    self.reminderEnabledButtonImages = @[@"reminder-day-of-enabled.png", @"reminder-day-before-enabled.png", @"reminder-week-enabled.png", @"reminder-week-enabled.png"];
    self.reminderDisabledButtonImages = @[@"reminder-day-of-disabled.png", @"reminder-day-before-disabled.png", @"reminder-week-disabled.png", @"reminder-week-disabled.png"];
    self.reminderArray = [NSMutableArray arrayWithArray:@[self.contact.hasReminderDayOf, self.contact.hasReminderDayBefore, self.contact.hasReminderWeekBefore, self.contact.hasReminderWeekAfter]];

	
    // Give the view a light background patter
    // -----------------------------------------------
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light-background.png"]];
    
    // Add the save and cancel buttons to the nav bar
    // as well as a title
    // -----------------------------------------------
    QueueBarButtonItem *cancelButton;
    switch (self.editContactType)
    {
        case QueueEditContactTypeAdd:
            cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeBack target:self action:@selector(back)];
            self.title = @"Add Contact";
            break;
            
        case QueueEditContactTypeUpdate:
            cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(close)];
            self.title = @"Edit Contact";
            break;
            
        default:
            cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(close)];
            self.title = @"Edit Contact";
            break;
    }
    
    QueueBarButtonItem *addMeetingButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeDone target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = addMeetingButton;
    
    // Add the text-based sections
    // -----------------------------------------------
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    UIFont *smallFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    UIColor *textColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1];
    UIColor *lightTextColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1];
    UIView *dividerLine = [[UIView alloc] init];
    dividerLine.backgroundColor = [UIColor blackColor];
    dividerLine.alpha = 0.2;
    
    // Add the due date section
    UIControl *dueDateViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                                                                  self.view.bounds.size.width, [self dueDateViewContainerHeight])];
    
    UILabel *intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(dueDateViewContainer.bounds.origin.x + DUE_DATE_MARGIN_LEFT,
                                                                       dueDateViewContainer.bounds.origin.y + DUE_DATE_MARGIN_TOP,
                                                                       dueDateViewContainer.bounds.size.width - DUE_DATE_MARGIN_LEFT - DUE_DATE_MARGIN_RIGHT,
                                                                       DUE_DATE_TEXT_HEIGHT)];
    
    UILabel *dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(dueDateViewContainer.bounds.origin.x + DUE_DATE_MARGIN_LEFT,
                                                                   dueDateViewContainer.bounds.origin.y + DUE_DATE_MARGIN_TOP + DUE_DATE_TEXT_HEIGHT,
                                                                   dueDateViewContainer.bounds.size.width - DUE_DATE_MARGIN_LEFT - DUE_DATE_MARGIN_RIGHT,
                                                                   DUE_DATE_SUBTEXT_HEIGHT)];
    
    UIView *dueDateDividerLine = [[UIView alloc] initWithFrame:CGRectMake(dueDateViewContainer.bounds.origin.x, dueDateViewContainer.bounds.size.height - 0.5,
                                                                          dueDateViewContainer.bounds.size.width, 0.5)];
    
    ContactImageView *thumbnailImageView = [[ContactImageView alloc] initWithFrame:CGRectMake((DUE_DATE_MARGIN_LEFT - THUMBNAIL_WIDTH)/2,
                                                                                    ((DUE_DATE_MARGIN_TOP + DUE_DATE_TEXT_HEIGHT + DUE_DATE_SUBTEXT_HEIGHT + DUE_DATE_MARGIN_BOTTOM) - THUMBNAIL_HEIGHT)/2, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];

    intervalLabel.font = font;
    intervalLabel.textColor = textColor;
    intervalLabel.text = [self intervalLabelText];
    self.intervalLabel = intervalLabel;
    
    dueDateLabel.font = smallFont;
    dueDateLabel.textColor = lightTextColor;
    dueDateLabel.text = [self dueDateLabelText];
    self.dueDateLabel = dueDateLabel;
    
    thumbnailImageView.image = [thumbnailImageView imageWithGloss:[self.contact image]];
    
    dueDateDividerLine.backgroundColor = [UIColor blackColor];
    dueDateDividerLine.alpha = 0.2;
    
    [dueDateViewContainer addTarget:self action:@selector(shouldEditIntervalField) forControlEvents:UIControlEventTouchUpInside];

    [dueDateViewContainer addSubview:self.intervalLabel];
    [dueDateViewContainer addSubview:self.dueDateLabel];
    [dueDateViewContainer addSubview:thumbnailImageView];
    [dueDateViewContainer addSubview:dueDateDividerLine];
    
    // Add the due date picker
    UIDatePicker *dueDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                              self.view.bounds.size.height,
                                                                              self.view.bounds.size.width,
                                                                              keyboardHeight)];
    dueDatePicker.datePickerMode = UIDatePickerModeDate;
    dueDatePicker.maximumDate = [NSDate date];
    dueDatePicker.date = [self.contact dueDateIncludingSnoozes:NO];
    [dueDatePicker addTarget:self action:@selector(datePickerDateDidChange:) forControlEvents:UIControlEventValueChanged];
    self.dueDatePicker = dueDatePicker;
    [self.view addSubview:self.dueDatePicker];
    
    
    // Add the interval section
//    UIControl *intervalViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
//                                                                                   self.view.bounds.origin.y + dueDateViewContainer.bounds.size.height,
//                                                                                   self.view.bounds.size.width, [self intervalViewContainerHeight])];
//    
//    UILabel *intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(intervalViewContainer.bounds.origin.x + INTERVAL_MARGIN_LEFT, INTERVAL_MARGIN_TOP,
//                                                                       intervalViewContainer.bounds.size.width - INTERVAL_MARGIN_LEFT - INTERVAL_MARGIN_RIGHT,
//                                                                       INTERVAL_TEXT_HEIGHT)];
//    
//    UIImageView *intervalIcon = [[UIImageView alloc] initWithFrame:CGRectMake((INTERVAL_MARGIN_LEFT - INTERVAL_ICON_WIDTH)/2,
//                                 ((INTERVAL_MARGIN_TOP + INTERVAL_TEXT_HEIGHT + INTERVAL_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
//                                 INTERVAL_ICON_WIDTH, ICON_HEIGHT)];
//    
//    
//    UIView *intervalDividerLine = [[UIView alloc] initWithFrame:CGRectMake(intervalViewContainer.bounds.origin.x, intervalViewContainer.bounds.size.height - 0.5,
//                                                                           intervalViewContainer.bounds.size.width, 0.5)];
//    
//    intervalLabel.font = font;
//    intervalLabel.textColor = textColor;
//    intervalLabel.text = [self intervalLabelText];
//    self.intervalLabel = intervalLabel;
//    
//    intervalIcon.image = [UIImage imageNamed:@"roundabout.png"];
//    
//    intervalDividerLine.backgroundColor = [UIColor blackColor];
//    intervalDividerLine.alpha = 0.2;
//    
//    [intervalViewContainer addTarget:self action:@selector(shouldEditIntervalField) forControlEvents:UIControlEventTouchUpInside];
//    
//    [intervalViewContainer addSubview:self.intervalLabel];
//    [intervalViewContainer addSubview:intervalIcon];
//    [intervalViewContainer addSubview:intervalDividerLine];
//    
//    // Add the interval picker
    UIPickerView *intervalPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                                  self.view.bounds.size.height,
                                                                                  self.view.bounds.size.width,
                                                                                  keyboardHeight)];
    
    intervalPicker.delegate = self;
    intervalPicker.dataSource = self;
    intervalPicker.showsSelectionIndicator = YES;
    self.intervalPicker = intervalPicker;
	
    NSBundle *bundle = [NSBundle mainBundle];
	NSString *plistPath = [bundle pathForResource:@"IntervalPicker" ofType:@"plist"];
	
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	self.intervalOptions = dictionary;
	
	NSArray *component = [self.intervalOptions allKeys];
	NSArray *sorted = [component sortedArrayUsingArray:@[@"Days", @"Weeks", @"Months", @"Years"]];
	self.timeType = sorted;
	
	NSString *selectedType = [self.timeType objectAtIndex:0];
	NSArray *selectedUnit = [self.intervalOptions objectForKey:selectedType];
	self.timeUnit = selectedUnit;
    
    [self selectPickerRows];
    

    // Add the note section
    UIControl *noteViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                               self.view.bounds.origin.y + dueDateViewContainer.bounds.size.height,
                                                                               self.view.bounds.size.width, [self noteViewContainerHeight])];

    UITextView *noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(NOTE_TEXT_INSET_LEFT, NOTE_TEXT_INSET_TOP,
                                                                        noteViewContainer.bounds.size.width - NOTE_TEXT_MARGIN_RIGHT,
                                                                        noteViewContainer.bounds.size.height - NOTE_TEXT_MARGIN_BOTTOM)];
    
    UIImageView *noteIcon = [[UIImageView alloc] initWithFrame:CGRectMake((NOTE_TEXT_MARGIN_LEFT - NOTE_ICON_WIDTH)/2,
                                                                          ((NOTE_TEXT_MARGIN_TOP + NOTE_TEXT_HEIGHT + NOTE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
                                                                          NOTE_ICON_WIDTH, ICON_HEIGHT)];
    
    noteTextView.font = font;
    noteTextView.textColor = textColor;
    noteTextView.contentInset = UIEdgeInsetsMake(0, 0, NOTE_TEXT_INSET_BOTTOM, NOTE_TEXT_INSET_RIGHT);
    noteTextView.text = self.contact.note;
    noteTextView.delegate = self;
    self.noteTextView = noteTextView;
    
    noteIcon.image = [UIImage imageNamed:@"notepad.png"];
    
    [noteViewContainer addTarget:self action:@selector(shouldEditNoteField) forControlEvents:UIControlEventTouchUpInside];
    
    [noteViewContainer addSubview:self.noteTextView];
    [noteViewContainer addSubview:noteIcon];


    // Add the reminder section
    UIControl *reminderViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                             self.view.bounds.origin.y + [self dueDateViewContainerHeight] + [self intervalViewContainerHeight] + [self noteViewContainerHeight],
                                                                             self.view.frame.size.width, [self reminderViewContainerHeight])];
    
    UILabel *reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(reminderViewContainer.bounds.origin.x + REMINDER_MARGIN_LEFT, REMINDER_MARGIN_TOP,
                                                                       reminderViewContainer.bounds.size.width - REMINDER_MARGIN_LEFT - REMINDER_MARGIN_RIGHT,
                                                                       REMINDER_TEXT_HEIGHT)];
    
    UIImageView *reminderIcon = [[UIImageView alloc] initWithFrame:CGRectMake((REMINDER_MARGIN_LEFT - REMINDER_ICON_WIDTH)/2,
                                                                              ((REMINDER_MARGIN_TOP + REMINDER_TEXT_HEIGHT + REMINDER_MARGIN_BOTTOM) - REMINDER_ICON_HEIGHT)/2,
                                                                              REMINDER_ICON_WIDTH, REMINDER_ICON_HEIGHT)];
    
    UIView *reminderDividerLineTop = [[UIView alloc] initWithFrame:CGRectMake(0, REMINDER_MARGIN_TOP + REMINDER_TEXT_HEIGHT + REMINDER_MARGIN_BOTTOM - 0.5,
                                                                              reminderViewContainer.bounds.size.width, 0.5)];
    
    UIView *reminderDividerLineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, REMINDER_MARGIN_TOP + REMINDER_TEXT_HEIGHT + REMINDER_MARGIN_BOTTOM,
                                                                                 reminderViewContainer.bounds.size.width, 0.5)];
    
    
    CGFloat reminderButtonHeight = (reminderViewContainer.frame.size.height - (REMINDER_MARGIN_TOP + REMINDER_TEXT_HEIGHT + REMINDER_MARGIN_BOTTOM)) / 2;
    CGFloat reminderButtonWidth = reminderViewContainer.frame.size.width / 2;
    NSArray *buttonStrings = @[@"Due Date", @"Day Before Due", @"Week Before Due", @"Week Overdue"];
    
    for (int r = 0; r < kNumberOfButtonRows; r++)
    {
        for (int c = 0; c < kNumberOfButtonColumns; c++)
        {
            CGFloat buttonOriginX = reminderButtonWidth * c;
            CGFloat buttonOriginY = (REMINDER_MARGIN_TOP + REMINDER_TEXT_HEIGHT + REMINDER_MARGIN_BOTTOM) + (reminderButtonHeight * r);
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonOriginX, buttonOriginY, reminderButtonWidth, reminderButtonHeight)];
            
            // Add target
            [button addTarget:self action:@selector(didTapReminderButton:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add image
            int index = r * kNumberOfButtonColumns + c;
            UIImage *buttonImage = [self reminderImageForIndex:index];
            NSString *buttonText = [buttonStrings objectAtIndex:index];
            button.contentMode = UIViewContentModeCenter;
            [button setImage:buttonImage forState:UIControlStateNormal];
            button.titleLabel.font = font;
            [button setTitle:buttonText forState:UIControlStateNormal];
            [button setTitleColor:textColor forState:UIControlStateNormal];
            button.showsTouchWhenHighlighted = YES;
            
            UIEdgeInsets titleInsets = UIEdgeInsetsMake(20, -1 * buttonImage.size.width, -20, 0);
            button.titleEdgeInsets = titleInsets;
            UIEdgeInsets imageInsets = UIEdgeInsetsMake(-25, 0, 0, -button.titleLabel.bounds.size.width);
            button.imageEdgeInsets = imageInsets;
            
            button.tag = index;
            
            [reminderViewContainer addSubview:button];
        }
    }
    
    reminderViewContainer.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
    
    reminderLabel.font = font;
    reminderLabel.textColor = textColor;
    reminderLabel.backgroundColor = [UIColor clearColor];
    self.reminderLabel = reminderLabel;
    self.reminderIcon = reminderIcon;
    [self updateReminderHeader];

    reminderDividerLineTop.backgroundColor = [UIColor blackColor];
    reminderDividerLineTop.alpha = 0.2;
    reminderDividerLineBottom.backgroundColor = [UIColor whiteColor];
    reminderDividerLineBottom.alpha = 0.2;
    
    UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    UIImageView *innerShadowView = [[UIImageView alloc] initWithImage:innerShadow];
    innerShadowView.frame = reminderViewContainer.bounds;
    
    [reminderViewContainer addTarget:self action:@selector(shouldEditReminderPreferences) forControlEvents:UIControlEventTouchUpInside];
    
    [reminderViewContainer addSubview:self.reminderLabel];
    [reminderViewContainer addSubview:self.reminderIcon];
    [reminderViewContainer addSubview:reminderDividerLineTop];
    [reminderViewContainer addSubview:reminderDividerLineBottom];
    [reminderViewContainer addSubview:innerShadowView];
    
    
    
    [self.view addSubview:dueDateViewContainer];
//    [self.view addSubview:intervalViewContainer];
    [self.view addSubview:noteViewContainer];
    [self.view addSubview:reminderViewContainer];
    
    [self.view addSubview:self.dueDatePicker];
    [self.view addSubview:self.intervalPicker];
    
    self.isDueDatePickerVisible = NO;
    self.isIntervalPickerVisible = NO;
    self.isKeyboardVisible = NO;
    
    [self registerForKeyboardNotifications];
    
//    [self.noteTextView becomeFirstResponder];
//    [self shouldEditIntervalField];
    [self performSelector:@selector(shouldEditIntervalField) withObject:nil afterDelay:0.25];
}

// ------------------------------
// Helper methods for determining
// view frame sizes and
// displaying dates
// ------------------------------
- (CGFloat)dueDateViewContainerHeight { return DUE_DATE_TEXT_HEIGHT + DUE_DATE_SUBTEXT_HEIGHT + DUE_DATE_MARGIN_TOP + DUE_DATE_MARGIN_BOTTOM; }
- (CGFloat)intervalViewContainerHeight { return /* INTERVAL_TEXT_HEIGHT + INTERVAL_MARGIN_TOP + INTERVAL_MARGIN_BOTTOM*/ 0; }
- (CGFloat)noteViewContainerHeight
{
    return self.view.bounds.size.height - keyboardHeight - self.navigationController.navigationBar.frame.size.height - NOTE_TEXT_HEIGHT - NOTE_TEXT_MARGIN_TOP - NOTE_TEXT_MARGIN_BOTTOM - [self dueDateViewContainerHeight] - [self intervalViewContainerHeight] - [UIApplication sharedApplication].statusBarFrame.size.height;
}
- (CGFloat)reminderViewContainerHeight
{
    return self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - ([self dueDateViewContainerHeight] + [self intervalViewContainerHeight] + [self noteViewContainerHeight]);
}

- (NSString *)dueDateLabelText { return [NSString stringWithFormat:@"Due on %@", [self stringForDueDate:[self.contact dueDateIncludingSnoozes:NO]]]; }
- (NSString *)intervalLabelText { return [NSString stringWithFormat:@"Catch up %@", [self stringForInterval:self.contact.meetInterval]]; }
- (NSString *)stringForDueDate:(NSDate *)dueDate
{
    NSDateFormatter *dueDateFormatter = [[NSDateFormatter alloc] init];
    [dueDateFormatter setDateFormat:@"EEEE, MMMM d, y"];
    return [dueDateFormatter stringFromDate:dueDate];
}
- (NSString *)stringForInterval:(NSNumber *)meetInterval
{	
	if (meetInterval)
    {
		int year = 31536000;
		int month = 2635200;
		int week = 604800;
		int day = 86400;
		
		int display = [meetInterval intValue];
		int remainderYear = (display % year);
		int remainderMonth = (display % month);
		int remainderWeek = (display % week);
		int remainderDay = (display % day);
		
		int divideMonth = (display / month);
		int divideWeek = (display / week);
		int divideDay = (display / day);
		
		if (remainderYear == 0)
			return @"once per year";
        
		else if (remainderMonth == 0)
        {
			if (divideMonth == 1)
				return @"once per month";
			else
				return [NSString stringWithFormat:@"every %d months", divideMonth];
        }
        
        else if (remainderWeek == 0)
        {
            if (divideWeek == 1)
                return @"once per week";
            else
                return [NSString stringWithFormat:@"every %d weeks", divideWeek];
        }
        
        else if (remainderDay == 0)
        {
            if (divideDay == 1)
                return @"once per day";
            else
                return [NSString stringWithFormat:@"every %d days", divideDay];
        }
	}
    
	return @"never";
}


#pragma mark - Interval Picker Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == kTypeComponent)
		return [self.timeType count];
    
	return [self.timeUnit count];
}

#pragma mark -
#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == kTypeComponent)
		return [self.timeType objectAtIndex:row];
    
	return [self.timeUnit objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == kTypeComponent)
    {
		NSString *selectedType = [self.timeType objectAtIndex:row];
		NSArray *selectedUnit = [self.intervalOptions objectForKey:selectedType];
		self.timeUnit = selectedUnit;
		
		[self.intervalPicker selectRow:0 inComponent:kUnitComponent animated:NO];
		[self.intervalPicker reloadComponent:kUnitComponent];
	}
	
	self.contact.meetInterval = [self determineInterval];
    self.intervalLabel.text = [self intervalLabelText];
    self.dueDateLabel.text = [self dueDateLabelText];
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	if (component == kUnitComponent)
		return 90;
	return 200;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectPickerRows {
	
	int year = 31536000;
	int month = 2635200;
	int week = 604800;
	int day = 86400;
    
	int display = [self.contact.meetInterval intValue];
	int remainderYear = (display % year);
	int remainderMonth = (display % month);
	int remainderWeek = (display % week);
	int remainderDay = (display % day);
    
	int divideMonth = (display / month);
	int divideWeek = (display / week);
	int divideDay = (display / day);
    
	if (remainderYear == 0)
        [self.intervalPicker selectRow:3 inComponent:kTypeComponent animated:NO];
	else if (remainderMonth == 0) {
		[self.intervalPicker selectRow:2 inComponent:kTypeComponent animated:NO];
		if (divideMonth == 1)
			[self.intervalPicker selectRow:0 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 2)
			[self.intervalPicker selectRow:1 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 3)
			[self.intervalPicker selectRow:2 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 4)
			[self.intervalPicker selectRow:3 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 5)
			[self.intervalPicker selectRow:4 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 6)
			[self.intervalPicker selectRow:5 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 7)
			[self.intervalPicker selectRow:6 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 8)
			[self.intervalPicker selectRow:7 inComponent:kUnitComponent animated:NO];
		else if (divideMonth == 9)
			[self.intervalPicker selectRow:8 inComponent:kUnitComponent animated:NO];
	}
	else if (remainderWeek == 0) {
		[self.intervalPicker selectRow:1 inComponent:kTypeComponent animated:NO];
		if (divideWeek == 1)
			[self.intervalPicker selectRow:0 inComponent:kUnitComponent animated:NO];
		else if (divideWeek == 2)
			[self.intervalPicker selectRow:1 inComponent:kUnitComponent animated:NO];
		else if (divideWeek == 3)
			[self.intervalPicker selectRow:2 inComponent:kUnitComponent animated:NO];
		else if (divideWeek == 4)
			[self.intervalPicker selectRow:3 inComponent:kUnitComponent animated:NO];
		else if (divideWeek == 5)
			[self.intervalPicker selectRow:4 inComponent:kUnitComponent animated:NO];
		else if (divideWeek == 6)
			[self.intervalPicker selectRow:5 inComponent:kUnitComponent animated:NO];
	}
	else if (remainderDay == 0) {
		[self.intervalPicker selectRow:0 inComponent:kTypeComponent animated:NO];
		if (divideDay == 1)
			[self.intervalPicker selectRow:0 inComponent:kUnitComponent animated:NO];
		else if (divideDay == 2)
			[self.intervalPicker selectRow:1 inComponent:kUnitComponent animated:NO];
		else if (divideDay == 3)
			[self.intervalPicker selectRow:2 inComponent:kUnitComponent animated:NO];
		else if (divideDay == 4)
			[self.intervalPicker selectRow:3 inComponent:kUnitComponent animated:NO];
		else if (divideDay == 5)
			[self.intervalPicker selectRow:4 inComponent:kUnitComponent animated:NO];
		else if (divideDay == 6)
			[self.intervalPicker selectRow:5 inComponent:kUnitComponent animated:NO];
	}
}

// ------------------------------
// Return an NSNumber representing
// the user's chosen meet interval
// ------------------------------
- (NSNumber *)determineInterval {
	
	// Set New Interval Value For Table
	NSInteger typeRow = [self.intervalPicker selectedRowInComponent:kTypeComponent];
	NSInteger unitRow = [self.intervalPicker selectedRowInComponent:kUnitComponent];
	
	NSString *days = [NSString stringWithFormat:@"Days"];
	NSString *weeks = [NSString stringWithFormat:@"Weeks"];
	NSString *months = [NSString stringWithFormat:@"Months"];
	NSString *years = [NSString stringWithFormat:@"Years"];
	
	NSString *type = [self.timeType objectAtIndex:typeRow];
	NSString *unit = [self.timeUnit objectAtIndex:unitRow];
	
	double interval = 0;
	
	if ([type isEqualToString:days])
		interval = ([unit doubleValue] * 86400);
	else if ([type isEqualToString:weeks])
		interval = ([unit doubleValue] * 604800);
	else if ([type isEqualToString:months])
		interval = ([unit doubleValue] * 2635200);
	else if ([type isEqualToString:years])
		interval = ([unit doubleValue] * 31536000);
    else 
        interval = ([unit doubleValue] * 2635200) * 3; /* Default to 3 months */
        
    return [[NSNumber alloc] initWithDouble:interval];
}

// ------------------------------
// Manage the showing and hiding
// of the keyboard and pickers
// ------------------------------

#pragma mark - Note View Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.isDueDatePickerVisible)
    {
        [self hideDueDatePickerAnimated:YES completion:^{[self.noteTextView becomeFirstResponder];}];
        return NO;
    }
    else if (self.isIntervalPickerVisible)
    {
        [self hideIntervalPickerAnimated:YES completion:^{[self.noteTextView becomeFirstResponder];}];
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - Date Picker & Keyboard Methods

- (void)shouldEditDueDateField
{
    if ([self.noteTextView isFirstResponder])
        [self.noteTextView resignFirstResponder];
    
    [self showDueDatePickerAnimated:YES completion:nil];
}

- (void)shouldEditIntervalField
{
    if ([self.noteTextView isFirstResponder])
        [self.noteTextView resignFirstResponder];
    
    [self showIntervalPickerAnimated:YES completion:nil];
}

- (void)shouldEditNoteField
{
    if (self.isDueDatePickerVisible)
    {
        [self hideDueDatePickerAnimated:YES completion:^{[self.noteTextView becomeFirstResponder];}];
    }
    else if (self.isIntervalPickerVisible)
    {
        [self hideIntervalPickerAnimated:YES completion:^{[self.noteTextView becomeFirstResponder];}];
    }
    else
    {
        [self.noteTextView becomeFirstResponder];
    }
}

- (void)shouldEditReminderPreferences
{
    if (self.isDueDatePickerVisible)
    {
        [self hideDueDatePickerAnimated:YES completion:nil];
    }
    else if (self.isIntervalPickerVisible)
    {
        [self hideIntervalPickerAnimated:YES completion:nil];
    }
    else if (self.isKeyboardVisible)
    {
        [self.noteTextView resignFirstResponder];
    }
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

- (void)showDueDatePickerAnimated:(BOOL)animated completion:(void (^)())completionBlock;
{
    if (self.isDueDatePickerVisible == NO) {
        CGRect newFrame = CGRectMake(self.view.bounds.origin.x,
                                     self.view.bounds.size.height - keyboardHeight,
                                     self.view.bounds.size.width,
                                     keyboardHeight);
        float duration = animated ? 0.25f : 0.0f;
        float delay = self.isKeyboardVisible ? 0.25f : 0.0f;
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                         animations:^{self.dueDatePicker.frame = newFrame;}
                         completion:^(BOOL finished){
                             [self setIsDueDatePickerVisible:YES];
                             if (completionBlock != nil)
                                 completionBlock();
                         }];
    }
}

- (void)hideDueDatePickerAnimated:(BOOL)animated completion:(void (^)())completionBlock;
{
    if (self.isDueDatePickerVisible == YES) {
        CGRect newFrame = CGRectMake(self.view.bounds.origin.x,
                                     self.view.bounds.size.height,
                                     self.view.bounds.size.width,
                                     keyboardHeight);
        float duration = animated ? 0.25f : 0.0f;
        float delay = 0.0f;
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                         animations:^{self.dueDatePicker.frame = newFrame;}
                         completion:^(BOOL finished){
                             [self setIsDueDatePickerVisible:NO];
                             if (completionBlock != nil)
                                 completionBlock();
                         }];
    }
}

- (void)showIntervalPickerAnimated:(BOOL)animated completion:(void (^)())completionBlock;
{
    if (self.isIntervalPickerVisible == NO) {
        CGRect newFrame = CGRectMake(self.view.bounds.origin.x,
                                     self.view.bounds.size.height - keyboardHeight,
                                     self.view.bounds.size.width,
                                     keyboardHeight);
        float duration = animated ? 0.25f : 0.0f;
        float delay = self.isKeyboardVisible ? 0.25f : 0.0f;
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                         animations:^{self.intervalPicker.frame = newFrame;}
                         completion:^(BOOL finished){
                             [self setIsIntervalPickerVisible:YES];
                             if (completionBlock != nil)
                                 completionBlock();
                         }];
    }
}

- (void)hideIntervalPickerAnimated:(BOOL)animated completion:(void (^)())completionBlock;
{
    if (self.isIntervalPickerVisible == YES) {
        CGRect newFrame = CGRectMake(self.view.bounds.origin.x,
                                     self.view.bounds.size.height,
                                     self.view.bounds.size.width,
                                     keyboardHeight);
        float duration = animated ? 0.25f : 0.0f;
        float delay = 0.0f;
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                         animations:^{self.intervalPicker.frame = newFrame;}
                         completion:^(BOOL finished){
                             [self setIsIntervalPickerVisible:NO];
                             if (completionBlock != nil)
                                 completionBlock();
                         }];
    }
}

// ------------------------------
// Handle changing reminder
// notification preferences
// ------------------------------

#pragma mark - Reminder Notification Methods

- (UIImage *)reminderImageForIndex:(NSInteger)index
{
    BOOL isEnabled = [[self.reminderArray objectAtIndex:index] boolValue];
    if (isEnabled)
        return [UIImage imageNamed:[self.reminderEnabledButtonImages objectAtIndex:index]];
    else
        return [UIImage imageNamed:[self.reminderDisabledButtonImages objectAtIndex:index]];
}

- (void)updateReminderHeader
{
    BOOL remindersEnabled = [self remindersEnabled];
    if (remindersEnabled)
    {
        [self.reminderIcon setImage:[UIImage imageNamed:@"reminder-icon.png"]];
        self.reminderLabel.text = @"Remind me to catch up";
    }
    else
    {
        [self.reminderIcon setImage:[UIImage imageNamed:@"reminder-icon-disabled.png"]];
        self.reminderLabel.text = @"Don't remind me to catch up";
    }
}

- (void)didTapReminderButton:(UIButton *)sender
{
    [self toggleReminderPreferenceForReminderIndex:sender.tag];
    [sender setImage:[self reminderImageForIndex:sender.tag] forState:UIControlStateNormal];
    [self updateReminderHeader];
}

- (BOOL)remindersEnabled
{
    BOOL remindersEnabled = NO;
    for (NSNumber *preference in self.reminderArray)
    {
        if ([preference boolValue])
        {
            remindersEnabled = YES;
            break;
        }
    }
    return remindersEnabled;
}

- (void)toggleReminderPreferenceForReminderIndex:(NSInteger)index
{
    BOOL reminderPreference = [[self.reminderArray objectAtIndex:index] boolValue];
    BOOL newPreference;
    if (reminderPreference)
        newPreference = NO;
    else
        newPreference = YES;
        
    switch (index)
    {
        case kReminderDayOfButton:
            self.contact.hasReminderDayOf = [NSNumber numberWithBool:newPreference];
            [self.reminderArray replaceObjectAtIndex:index withObject:self.contact.hasReminderDayOf];
            break;
            
        case kReminderDayBeforeButton:
            self.contact.hasReminderDayBefore = [NSNumber numberWithBool:newPreference];
            [self.reminderArray replaceObjectAtIndex:index withObject:self.contact.hasReminderDayBefore];
            break;
            
        case kReminderWeekBeforeButton:
            self.contact.hasReminderWeekBefore = [NSNumber numberWithBool:newPreference];
            [self.reminderArray replaceObjectAtIndex:index withObject:self.contact.hasReminderWeekBefore];
            break;
            
        case kReminderWeekAfterButton:
            self.contact.hasReminderWeekAfter = [NSNumber numberWithBool:newPreference];
            [self.reminderArray replaceObjectAtIndex:index withObject:self.contact.hasReminderWeekAfter];
            break;
            
        default:
            break;
    }
}

@end
