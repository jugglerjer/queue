//
//  LLLocationManager.m
//  Queue
//
//  Created by Jeremy Lubin on 8/5/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLLocationManager.h"
#import "SBJSON.h"

@implementation LLLocationManager

static NSString *const googleGeocodeURL =  @"https://maps.googleapis.com/maps/api/geocode/json?";
static NSString *const googlePlacesTextSearchURL = @"https://maps.googleapis.com/maps/api/place/textsearch/json?key=AIzaSyDJk6VmHmcNveBQjDV91rJ3U4ExV0b4vIc";
static NSString *const googlePlacesNearbySearchURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDJk6VmHmcNveBQjDV91rJ3U4ExV0b4vIc";

- (id)initWithDesiredAccuracy:(CLLocationAccuracy)accuracy
{
    if (self == [super init])
    {
        // Create the location manager if this object does not
        // already have one.
        if (nil == _locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        // Set a movement threshold for new events.
        _locationManager.distanceFilter = 10;
    }
    NSLog(@"Initiatied location mananger");
    return self;
}

// Start the location manager
- (void)startStandardUpdates
{    
    NSLog(@"Updating location...");
    [_locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NSLog(@"Received location update");
    if (abs(howRecent) < 15.0)
    {
        // If the event is recent, do something with it.
        LLDataDownloader *downloader = [[LLDataDownloader alloc] init];
        downloader.delegate = self;
        NSString *url = [NSString stringWithFormat:@"%@latlng=%f,%f&sensor=true", googleGeocodeURL, location.coordinate.latitude, location.coordinate.longitude];
        [downloader getDataWithURL:url];
        NSLog(@"Fetching Google data: %@", url);
    }
}

// Handle errors in location detection
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

// Receive reverse geocode events from Google so we can display the user's location in a human-readable format
- (void)dataHasFinishedDownloadingForDownloader:(LLDataDownloader *)downloader withResult:(BOOL)result andData:(NSData *)data
{
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *locations = [jsonParser objectWithString:responseString];
    NSLog(@"Found location: %@", [[locations objectForKey:@"results"] objectAtIndex:0]);
    
    if ([_delegate respondsToSelector:@selector(locationManager:didFinishGeocodingLocation:)])
        [_delegate locationManager:self didFinishGeocodingLocation:[[locations objectForKey:@"results"] objectAtIndex:0]];
}

@end
