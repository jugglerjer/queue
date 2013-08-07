//
//  LLLocationManager.h
//  Queue
//
//  Created by Jeremy Lubin on 8/5/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LLDataDownloader.h"

@protocol LLLocationManagerDelegate;

@interface LLLocationManager : NSObject <CLLocationManagerDelegate, LLDataDownloaderDelegate>

@property (nonatomic, assign) id<LLLocationManagerDelegate> delegate;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (id)initWithDesiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)startStandardUpdates;

@end

@protocol LLLocationManagerDelegate <NSObject>

- (void)locationManager:(LLLocationManager *)locationManger didFinishGeocodingLocation:(NSDictionary *)location;

@end
