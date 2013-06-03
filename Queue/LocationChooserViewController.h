//
//  LocationChooserViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/29/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LLDataDownloader.h"
@class Meeting;
@class Location;

@protocol LocationChooseViewControllerDelegate;

typedef enum
{
    LocationChooserViewModeLocationEnabled,
    LocationChooserViewModeLocationDisabled,
    LocationChooserViewModeLocationSearch
} LocationChooserViewMode;

@interface LocationChooserViewController : UIViewController <CLLocationManagerDelegate, LLDataDownloaderDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id<LocationChooseViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Meeting *meeting;
@property (strong, nonatomic) Location *location;

- (void)activateWithAnimation:(BOOL)animation;
- (void)resignWithAnimation:(BOOL)animation;
- (void)updateLocationViewMode:(LocationChooserViewMode)mode;
- (void)clearLocations;

@end

@protocol LocationChooseViewControllerDelegate <NSObject>

- (void)locationChooserShouldBecomeActive:(LocationChooserViewController *)locationChooser;
- (void)locationChooserShouldBecomeInactive:(LocationChooserViewController *)locationChooser;
- (void)locationChooser:(LocationChooserViewController *)locationChooser didSelectLocation:(Location *)location forMeeting:(Meeting *)meeting;
- (void)locationChooser:(LocationChooserViewController *)locationChooser didRemoveLocation:(Location *)location forMeeting:(Meeting *)meeting;

@end
