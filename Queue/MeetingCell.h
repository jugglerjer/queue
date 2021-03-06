//
//  MeetingCell.h
//  Queue
//
//  Created by Jeremy Lubin on 5/26/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "LLDataDownloader.h"
#import "LLSwipeyCell.h"
@class Meeting;

@protocol MeetingCellDelegate;

@interface MeetingCell : LLSwipeyCell <LLDataDownloaderDelegate>

@property (nonatomic, assign) id<MeetingCellDelegate> delegate;
@property (strong, nonatomic) Meeting *meeting;

@property (strong, nonatomic) UILabel *noteLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) UILabel *deleteLabel;
@property (strong, nonatomic) UIButton *confirmDeleteButton;
@property (strong, nonatomic) UIButton *cancelDeleteButton;

@property (strong, nonatomic) UIView *topLine;
@property (strong, nonatomic) UIView *bottomLine;
@property (strong, nonatomic) UIView *tableTopLine;
@property (strong, nonatomic) UIView *tableBottomLine;
@property (strong, nonatomic) UIView *mapTopLineDark;
@property (strong, nonatomic) UIView *mapTopLineLight;
@property (strong, nonatomic) UIView *mapBottomLine;
@property (strong, nonatomic) UIView *timeline;
@property (strong, nonatomic) GMSMapView *mapView_;
@property (strong, nonatomic) UIImageView *mapView;
@property (strong, nonatomic) UIView *mapViewBackground;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithMeeting:(Meeting *)meeting;

@end

@protocol MeetingCellDelegate <NSObject, LLSwipeyCellDelegate>

- (void)meetingCell:(MeetingCell *)meetingCell didDeleteMeeting:(Meeting *)meeting;

@end
