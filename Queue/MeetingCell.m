//
//  MeetingCell.m
//  Queue
//
//  Created by Jeremy Lubin on 5/26/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "MeetingCell.h"
#import "Meeting.h"
#import "Location.h"

#define MARGIN_TOP      20
#define MARGIN_BOTTOM   20
#define MARGIN_LEFT     63
#define MARGIN_RIGHT    30

#define NOTE_HEIGHT     20
#define DATE_HEIGHT     18

#define MAP_HEIGHT      100

#define TIMELINE_MARGIN_LEFT    36
#define TIMELINE_WIDTH          2

#define DELETE_ICON_WIDTH    15
#define DELETE_ICON_MARGIN   8


@implementation MeetingCell

@synthesize mapView_;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithDetailType:LLSwipeyCellDetailTypeAdjacent reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        // Set the threshold after which the event is deleted on drag
        self.dragThreshold = self.frame.size.width * 0.75;
        
//        UIView *background = [[UIView alloc] initWithFrame:self.frame];
//        background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"queue_background.png"]];
//        background.backgroundColor = [UIColor whiteColor];
//        self.backgroundView = background;
        self.swipeyView.backgroundColor = [UIColor whiteColor];
//        self.contentView.backgroundColor = [UIColor whiteColor];
        self.underView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"queue_background.png"]];
        self.underView.backgroundColor = [UIColor orangeColor];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT,
                                                                       MARGIN_TOP,
                                                                       self.bounds.size.width - MARGIN_LEFT - MARGIN_RIGHT,
                                                                       DATE_HEIGHT)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        dateLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = dateLabel;
        [self.swipeyView addSubview:self.dateLabel];
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT,
                                                                       MARGIN_TOP + DATE_HEIGHT,
                                                                       self.bounds.size.width - MARGIN_LEFT - MARGIN_RIGHT,
                                                                       NOTE_HEIGHT)];
        noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        noteLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.numberOfLines = 0;
        self.noteLabel = noteLabel;
        [self.swipeyView addSubview:self.noteLabel];
        
        CGRect mapFrame = CGRectMake(0, self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 0.5, self.frame.size.width, 0);
        UIView *mapViewBackground = [[UIView alloc] initWithFrame:mapFrame];
        mapViewBackground.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1];
        UIImageView *mapView = [[UIImageView alloc] initWithFrame:mapFrame];
        mapView.backgroundColor = [UIColor clearColor];
        self.mapViewBackground = mapViewBackground;
        self.mapView = mapView;
        [self.swipeyView addSubview:self.mapViewBackground];
        [self.swipeyView addSubview:self.mapView];
//        mapView_ = [GMSMapView mapWithFrame:mapFrame camera:nil];
//        mapView_.settings.scrollGestures = NO;
//        mapView_.settings.zoomGestures = NO;
//        mapView_.userInteractionEnabled = NO;
//        [self addSubview:mapView_];
        
        CGRect lineFrame = CGRectMake(0,0,self.bounds.size.width, 0.5);

        UIView *topLine = [[UIView alloc] initWithFrame:lineFrame];
        topLine.backgroundColor = [UIColor whiteColor];
        topLine.alpha = 0.2;
        self.topLine = topLine;
        [self.swipeyView addSubview:self.topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor blackColor];
        bottomLine.alpha = 0.1;
        self.bottomLine = bottomLine;
        [self.swipeyView addSubview:self.bottomLine];
    
        UIView *mapTopLineDark = [[UIView alloc] initWithFrame:lineFrame];
        mapTopLineDark.backgroundColor = [UIColor whiteColor];
        mapTopLineDark.alpha = 0.2;
        self.mapTopLineDark = mapTopLineDark;
        [self.swipeyView addSubview:self.mapTopLineDark];
        
        UIView *mapTopLineLight = [[UIView alloc] initWithFrame:lineFrame];
        mapTopLineLight.backgroundColor = [UIColor whiteColor];
        mapTopLineLight.alpha = 0.2;
        self.mapTopLineLight = mapTopLineLight;
        [self.swipeyView addSubview:self.mapTopLineLight];
        
        UIView *mapBottomLine = [[UIView alloc] initWithFrame:lineFrame];
        mapBottomLine.backgroundColor = [UIColor blackColor];
        mapBottomLine.alpha = 0.1;
        self.mapBottomLine = mapBottomLine;
        [self.swipeyView addSubview:self.mapBottomLine];
        
//        UIView *tableTopLine = [[UIView alloc] initWithFrame:lineFrame];
//        tableTopLine.backgroundColor = [UIColor blackColor];
//        tableTopLine.alpha = 0;
//        self.tableTopLine = tableTopLine;
//        [self addSubview:self.tableTopLine];
//        
//        UIView *tableBottomLine = [[UIView alloc] initWithFrame:lineFrame];
//        tableBottomLine.backgroundColor = [UIColor whiteColor];
//        tableBottomLine.alpha = 0;
//        self.tableBottomLine = tableBottomLine;
//        [self addSubview:self.tableBottomLine];
        
//        UIView *timeline = [[UIView alloc] initWithFrame:CGRectMake(TIMELINE_MARGIN_LEFT, 0, TIMELINE_WIDTH, 0)];
//        timeline.backgroundColor = [UIColor blackColor];
//        timeline.alpha = 0.2;
//        self.timeline = timeline;
//        [self addSubview:self.timeline];
        
        // Create delete underview        
        self.deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(DELETE_ICON_MARGIN*2 + DELETE_ICON_WIDTH,
                                                                     0,
                                                                     self.frame.size.width - DELETE_ICON_WIDTH*2 - DELETE_ICON_MARGIN*4,
                                                                     self.frame.size.height)];
        _deleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        _deleteLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4];
        _deleteLabel.shadowColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
        _deleteLabel.shadowOffset = CGSizeMake(0, -0.5);
        _deleteLabel.backgroundColor = [UIColor clearColor];
        _deleteLabel.text = @"Slide to delete";
        [self.underView addSubview:_deleteLabel];
        
        // Adjust the underview position
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)configureWithMeeting:(Meeting *)meeting
{    
    _meeting = meeting;
    
    self.noteLabel.text = meeting.note;
    [self.noteLabel sizeToFit];
    
    NSString *locationString;
    CGRect mapFrame;
//    GMSCameraPosition *camera;
//    [mapView_ setCamera:nil];
//    [mapView_ removeFromSuperview];
//    [mapView_ clear];
    
    NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
    [meetingDateFormatter setDateFormat:@"MMMM d, y"];
    NSString *dateString = [meetingDateFormatter stringFromDate:meeting.date];
    
    if (meeting.location) {
        
        CGRect lineFrame = CGRectMake(0,0,self.bounds.size.width, 0.5);
        
        lineFrame.origin.y = self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM;
        self.mapTopLineDark.frame = lineFrame;
        self.mapTopLineDark.alpha = 0.1;
        
//        lineFrame.origin.y = self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 0.5;
//        self.mapTopLineDark.frame = lineFrame;
//        self.mapTopLineDark.alpha = 0.1;
        
        lineFrame.origin.y = self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 0.5;
//        lineFrame.origin.y = MAP_HEIGHT - 0.5;
        self.mapBottomLine.frame = lineFrame;
        self.mapBottomLine.alpha = 0.2;
    
        mapFrame = CGRectMake(0, self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 0.5, self.frame.size.width, MAP_HEIGHT);
//        camera = [GMSCameraPosition cameraWithLatitude:[meeting.location.latitude doubleValue]
//                                                                longitude:[meeting.location.longitude doubleValue]
//                                                                     zoom:15];
//        [self addSubview:mapView_];
//        [mapView_ performSelector:@selector(startRendering) onThread:[NSThread new] withObject:nil waitUntilDone:NO];
//        
//        GMSMarker *marker = [[GMSMarker alloc] init];
//        marker.position = CLLocationCoordinate2DMake([meeting.location.latitude doubleValue], [meeting.location.longitude doubleValue]);
//        marker.title = [meeting.location title];
//        marker.snippet = [meeting.location subtitle];
//        marker.map = mapView_;
        
        locationString = [meeting.location title];
        self.dateLabel.text = [NSString stringWithFormat:@"%@ | %@", dateString, locationString];
    }
    else {
        self.mapTopLineDark.alpha = 0;
        self.mapBottomLine.alpha = 0;
        mapFrame = CGRectMake(0, self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 0.5, self.frame.size.width, 0);
//        camera = nil;
//        [mapView_ stopRendering];
        self.dateLabel.text = dateString;
    }
    
    [self.mapViewBackground setFrame:mapFrame];
    [self.mapView setFrame:mapFrame];
//    [mapView_ setCamera:camera];
//    [mapView_ stopRendering];
//    [mapView_ performSelector:@selector(stopRendering) withObject:nil afterDelay:0.4];
    
    [self resizeCellElements];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// -------------------------
// Resize any elements of the
// cell that depend on it's height
// -------------------------
- (void)resizeCellElements
{
    CGRect lineFrame = CGRectMake(0,0,self.bounds.size.width, 0.5);
    
    lineFrame.origin.y = [self height] - 0.5;
    self.bottomLine.frame = lineFrame;
    
    CGRect viewFrame = self.frame;
    viewFrame.size.height = [self height];
    
    CGRect underViewFrame = self.underView.frame;
    CGRect swipeyViewFrame = self.swipeyView.frame;
    underViewFrame.size.height = [self height];
    swipeyViewFrame.size.height = [self height];
    [self.underView setFrame:underViewFrame];
    [self.swipeyView setFrame:swipeyViewFrame];
    
    CGRect deleteFrame = _deleteLabel.frame;
    deleteFrame.size.height = [self height];
    [_deleteLabel setFrame:deleteFrame];
}

- (CGFloat)height
{
    NSString *text = _noteLabel.text;
    CGSize constraint = CGSizeMake(self.frame.size.width - MARGIN_LEFT - MARGIN_RIGHT, 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0] constrainedToSize:constraint];
    
    int mapHeight = 0;
    if (_meeting.location)
        mapHeight = 100.5;
    
    return size.height + MARGIN_TOP + MARGIN_BOTTOM + DATE_HEIGHT + mapHeight + 1;
}

@end
