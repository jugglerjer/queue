//
//  MeetingCell.m
//  Queue
//
//  Created by Jeremy Lubin on 5/26/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
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

@implementation MeetingCell

GMSMapView *mapView_;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIView *background = [[UIView alloc] initWithFrame:self.frame];
        background.backgroundColor = [UIColor whiteColor];
        self.backgroundView = background;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT,
                                                                       MARGIN_TOP,
                                                                       self.bounds.size.width - MARGIN_LEFT - MARGIN_RIGHT,
                                                                       DATE_HEIGHT)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        dateLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = dateLabel;
        [self addSubview:self.dateLabel];
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT,
                                                                       MARGIN_TOP + DATE_HEIGHT,
                                                                       self.bounds.size.width - MARGIN_LEFT - MARGIN_RIGHT,
                                                                       NOTE_HEIGHT)];
        noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        noteLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.numberOfLines = 0;
        self.noteLabel = noteLabel;
        [self addSubview:self.noteLabel];
        
        CGRect mapFrame = CGRectMake(0, self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 1, self.frame.size.width, 0);
        mapView_ = [GMSMapView mapWithFrame:mapFrame camera:nil];
        mapView_.settings.scrollGestures = NO;
        mapView_.settings.zoomGestures = NO;
        mapView_.userInteractionEnabled = NO;
        [self addSubview:mapView_];
        
        CGRect lineFrame = CGRectMake(0,0,self.bounds.size.width, 0.5);

        UIView *topLine = [[UIView alloc] initWithFrame:lineFrame];
        topLine.backgroundColor = [UIColor whiteColor];
        topLine.alpha = 0.2;
        self.topLine = topLine;
        [self addSubview:self.topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor blackColor];
        bottomLine.alpha = 0.1;
        self.bottomLine = bottomLine;
        [self addSubview:self.bottomLine];
    
        UIView *mapTopLine = [[UIView alloc] initWithFrame:lineFrame];
        mapTopLine.backgroundColor = [UIColor whiteColor];
        mapTopLine.alpha = 0.2;
        self.mapTopLine = mapTopLine;
        [self addSubview:self.mapTopLine];
        
        UIView *mapBottomLine = [[UIView alloc] initWithFrame:lineFrame];
        mapBottomLine.backgroundColor = [UIColor blackColor];
        mapBottomLine.alpha = 0.1;
        self.mapBottomLine = mapBottomLine;
        [self addSubview:self.mapBottomLine];
        
        UIView *tableTopLine = [[UIView alloc] initWithFrame:lineFrame];
        tableTopLine.backgroundColor = [UIColor blackColor];
        tableTopLine.alpha = 0;
        self.tableTopLine = tableTopLine;
        [self addSubview:self.tableTopLine];
        
        UIView *tableBottomLine = [[UIView alloc] initWithFrame:lineFrame];
        tableBottomLine.backgroundColor = [UIColor whiteColor];
        tableBottomLine.alpha = 0;
        self.tableBottomLine = tableBottomLine;
        [self addSubview:self.tableBottomLine];
        
//        UIView *timeline = [[UIView alloc] initWithFrame:CGRectMake(TIMELINE_MARGIN_LEFT, 0, TIMELINE_WIDTH, 0)];
//        timeline.backgroundColor = [UIColor blackColor];
//        timeline.alpha = 0.2;
//        self.timeline = timeline;
//        [self addSubview:self.timeline];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)configureWithMeeting:(Meeting *)meeting
{
    self.noteLabel.text = meeting.note;
    [self.noteLabel sizeToFit];
    
    NSString *locationString;
    if (meeting.location) {
        
        CGRect lineFrame = CGRectMake(0,0,self.bounds.size.width, 0.5);
        
        lineFrame.origin.y = self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM;
        self.mapTopLine.frame = lineFrame;
        
        lineFrame.origin.y = self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 0.5;
        self.mapBottomLine.frame = lineFrame;
        
        CGRect mapFrame = CGRectMake(0, self.noteLabel.frame.origin.y + self.noteLabel.frame.size.height + MARGIN_BOTTOM + 1, self.frame.size.width, MAP_HEIGHT);
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[meeting.location.latitude doubleValue]
                                                                longitude:[meeting.location.longitude doubleValue]
                                                                     zoom:15];
        [mapView_ setFrame:mapFrame];
        [mapView_ setCamera:camera];
        [mapView_ clear];
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([meeting.location.latitude doubleValue], [meeting.location.longitude doubleValue]);
        marker.title = [meeting.location title];
        marker.snippet = [meeting.location subtitle];
        marker.map = mapView_;
        
        locationString = [meeting.location title];
    }
    
    NSDateFormatter *meetingDateFormatter = [[NSDateFormatter alloc] init];
    [meetingDateFormatter setDateFormat:@"MMMM d, y"];
    NSString *dateString = [meetingDateFormatter stringFromDate:meeting.date];
    
    if (meeting.location)
        self.dateLabel.text = [NSString stringWithFormat:@"%@ | %@", dateString, locationString];
    else
        self.dateLabel.text = dateString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
