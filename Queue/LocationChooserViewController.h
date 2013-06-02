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

@interface LocationChooserViewController : UIViewController <CLLocationManagerDelegate, LLDataDownloaderDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Meeting *meeting;

@end
