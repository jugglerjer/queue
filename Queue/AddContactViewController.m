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

#define DUE_DATE_MARGIN_LEFT       48
#define DUE_DATE_MARGIN_RIGHT      13
#define DUE_DATE_MARGIN_TOP        20
#define DUE_DATE_MARGIN_BOTTOM     20
#define DUE_DATE_TEXT_HEIGHT       15

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

#define ICON_HEIGHT                  14
#define ICON_WIDTH                   13

@interface AddContactViewController ()

@property (strong, nonatomic) UILabel *dueDateLabel;
@property (strong, nonatomic) UILabel *intervalLabel;
@property (strong, nonatomic) UITextView *noteTextView;

@end

@implementation AddContactViewController

static CGFloat keyboardHeight = 216;

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
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// ------------------------------
// Dismiss the view without saving
// when the user taps the check
// ------------------------------
- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Give the view a light background patter & a title
    // -----------------------------------------------
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light-background.png"]];
    self.title = @"Edit Contact";
    
    // Add the save and cancel buttons to the nav bar
    // -----------------------------------------------
    QueueBarButtonItem *cancelButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeCancel target:self action:@selector(close)];
    QueueBarButtonItem *addMeetingButton = [[QueueBarButtonItem alloc] initWithType:QueueBarButtonItemTypeDone target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = addMeetingButton;
    
    // Add the text-based sections
    // -----------------------------------------------
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    UIColor *textColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1];
    UIView *dividerLine = [[UIView alloc] init];
    dividerLine.backgroundColor = [UIColor blackColor];
    dividerLine.alpha = 0.2;
    
    // Add the due date section
    UIControl *dueDateViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                                                                  self.view.bounds.size.width, [self dueDateViewContainerHeight])];
    
    UILabel *dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(dueDateViewContainer.bounds.origin.x + DUE_DATE_MARGIN_LEFT,
                                                                   dueDateViewContainer.bounds.origin.y + DUE_DATE_MARGIN_TOP,
                                                                   dueDateViewContainer.bounds.size.width - DUE_DATE_MARGIN_LEFT - DUE_DATE_MARGIN_RIGHT,
                                                                   DUE_DATE_TEXT_HEIGHT)];
    
    UIView *dueDateDividerLine = [[UIView alloc] initWithFrame:CGRectMake(dueDateViewContainer.bounds.origin.x, dueDateViewContainer.bounds.size.height - 0.5,
                                                                          dueDateViewContainer.bounds.size.width, 0.5)];

    dueDateLabel.font = font;
    dueDateLabel.textColor = textColor;
    dueDateLabel.text = [NSString stringWithFormat:@"Next due on %@", [self stringForDueDate:[self.contact dueDate]]];
    self.dueDateLabel = dueDateLabel;
    
    dueDateDividerLine.backgroundColor = [UIColor blackColor];
    dueDateDividerLine.alpha = 0.2;
    
//    UIImageView *calendarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_full.png"]];
//    calendarIcon.frame = CGRectMake((DATE_TEXT_MARGIN_LEFT - ICON_WIDTH)/2,
//                                    ((DATE_TEXT_MARGIN_TOP + DATE_TEXT_HEIGHT + DATE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
//                                    ICON_WIDTH,
//                                    ICON_HEIGHT);
    
//    [dueDateViewContainer addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
//    [dueDateViewContainer addSubview:calendarIcon];
    [dueDateViewContainer addSubview:self.dueDateLabel];
    [dueDateViewContainer addSubview:dueDateDividerLine];
    
    
    // Add the interval section
    UIControl *intervalViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                                   self.view.bounds.origin.y + dueDateViewContainer.bounds.size.height,
                                                                                   self.view.bounds.size.width, [self intervalViewContainerHeight])];
    
    UILabel *intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(intervalViewContainer.bounds.origin.x + INTERVAL_MARGIN_LEFT, INTERVAL_MARGIN_TOP,
                                                                       intervalViewContainer.bounds.size.width - INTERVAL_MARGIN_LEFT - INTERVAL_MARGIN_RIGHT,
                                                                       INTERVAL_TEXT_HEIGHT)];
    
    UIView *intervalDividerLine = [[UIView alloc] initWithFrame:CGRectMake(intervalViewContainer.bounds.origin.x, intervalViewContainer.bounds.size.height - 0.5,
                                                                           intervalViewContainer.bounds.size.width, 0.5)];
    
    intervalLabel.font = font;
    intervalLabel.textColor = textColor;
    intervalLabel.text = [NSString stringWithFormat:@"Catch up %@", [self stringForInterval:self.contact.meetInterval]];
    self.intervalLabel = intervalLabel;
    
    intervalDividerLine.backgroundColor = [UIColor blackColor];
    intervalDividerLine.alpha = 0.2;
    
    // TODO add target
    // TODO add icon
    [intervalViewContainer addSubview:self.intervalLabel];
    [intervalViewContainer addSubview:intervalDividerLine];   
    

    // Add the note section
    UIControl *noteViewContainer = [[UIControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                               self.view.bounds.origin.y + dueDateViewContainer.bounds.size.height + intervalViewContainer.bounds.size.height,
                                                                               self.view.bounds.size.width, [self intervalViewContainerHeight])];

    UITextView *noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(NOTE_TEXT_INSET_LEFT, NOTE_TEXT_INSET_TOP,
                                                                        noteViewContainer.bounds.size.width - NOTE_TEXT_MARGIN_RIGHT,
                                                                        noteViewContainer.bounds.size.height - NOTE_TEXT_MARGIN_BOTTOM)];
    
    UIImageView *noteIcon = [[UIImageView alloc] initWithFrame:CGRectMake((NOTE_TEXT_MARGIN_LEFT - ICON_WIDTH)/2,
                                                                          ((NOTE_TEXT_MARGIN_TOP + NOTE_TEXT_HEIGHT + NOTE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
                                                                          ICON_WIDTH, ICON_HEIGHT)];
    
    noteTextView.font = font;
    noteTextView.textColor = textColor;
    noteTextView.contentInset = UIEdgeInsetsMake(0, 0, NOTE_TEXT_INSET_BOTTOM, NOTE_TEXT_INSET_RIGHT);
    noteTextView.text = self.contact.note;
    noteTextView.delegate = self;
    
    noteIcon.image = [UIImage imageNamed:@"notepad.png"];
    
    self.noteTextView = noteTextView;
    
    [noteViewContainer addSubview:self.noteTextView];
    [noteViewContainer addSubview:noteIcon];

    
    
    
    // Add the reminder section
    
    
    [self.view addSubview:dueDateViewContainer];
    [self.view addSubview:intervalViewContainer];
    [self.view addSubview:noteViewContainer];    
}

// ------------------------------
// Helper methods for determining
// view frame sizes and
// displaying dates
// ------------------------------
- (CGFloat)dueDateViewContainerHeight { return DUE_DATE_TEXT_HEIGHT + DUE_DATE_MARGIN_TOP + DUE_DATE_MARGIN_BOTTOM; }
- (CGFloat)intervalViewContainerHeight { return INTERVAL_TEXT_HEIGHT + INTERVAL_MARGIN_TOP + INTERVAL_MARGIN_BOTTOM; }
- (CGFloat)noteViewContainerHeight
{
    return self.view.bounds.size.height - keyboardHeight - self.navigationController.navigationBar.frame.size.height - NOTE_TEXT_HEIGHT - NOTE_TEXT_MARGIN_TOP - NOTE_TEXT_MARGIN_BOTTOM - [self dueDateViewContainerHeight] - [self intervalViewContainerHeight];
}
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
