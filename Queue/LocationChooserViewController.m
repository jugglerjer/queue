//
//  LocationChooserViewController.m
//  Queue
//
//  Created by Jeremy Lubin on 5/29/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "LocationChooserViewController.h"
#import "SBJSON.h"


#define PLACE_TEXT_MARGIN_LEFT       48
#define PLACE_TEXT_MARGIN_RIGHT      48
#define PLACE_TEXT_MARGIN_TOP        14
#define PLACE_TEXT_MARGIN_BOTTOM     11
#define PLACE_TEXT_HEIGHT            15

#define ICON_HEIGHT                  18
#define ICON_WIDTH                   12

@interface LocationChooserViewController ()

@property (strong, nonatomic) UILabel *locationTitleView;
@property (strong, nonatomic) UILabel *locationSubtitleView;
@property (strong, nonatomic) CLLocation *selectedLocation;

@end

@implementation LocationChooserViewController

GMSMapView *mapView_;
static NSString *const googleGeocodeURL =  @"https://maps.googleapis.com/maps/api/geocode/json?";

// Start the location manager
- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 10;
    
    [self.locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        // If the event is recent, do something with it.
        LLDataDownloader *downloader = [[LLDataDownloader alloc] init];
        downloader.delegate = self;
        NSString *url = [NSString stringWithFormat:@"%@latlng=%f,%f&sensor=true", googleGeocodeURL, location.coordinate.latitude, location.coordinate.longitude];
        [downloader getDataWithURL:url];
        self.selectedLocation = location;
    }
}

// Receive reverse geocode events from Google so we can display the user's location in a human-readable format
- (void)dataHasFinishedDownloadingForDownloader:(LLDataDownloader *)downloader withResult:(BOOL)result andData:(NSData *)data
{
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *locations = [jsonParser objectWithString:responseString];
    NSArray *address = [[[locations objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"];
    
    // Loop through the first location returned to parse all of the address components we may way to display
    NSMutableDictionary *addressComponents = [NSMutableDictionary dictionaryWithCapacity:5];
    
    for (NSDictionary *component in address)
    {
        NSArray *types = [component objectForKey:@"types"];
        NSString *name = [component objectForKey:@"long_name"];
        if ([types containsObject:@"street_number"])
        {
            [addressComponents setObject:name forKey:@"street_number"];
        }
        if ([types containsObject:@"route"])
        {
            [addressComponents setObject:name forKey:@"route"];
        }
        if ([types containsObject:@"neighborhood"])
        {
            [addressComponents setObject:name forKey:@"neighborhood"];
        }
        if ([types containsObject:@"locality"])
        {
            [addressComponents setObject:name forKey:@"locality"];
        }
        if ([types containsObject:@"point_of_interest"])
        {
            [addressComponents setObject:name forKey:@"point_of_interest"];
        }
    }
    
    [self displayLocation:addressComponents];
}

- (void)displayLocation:(NSDictionary *)address
{
    if ([address objectForKey:@"place_of_interest"])
    {
        self.locationTitleView.text = [address objectForKey:@"place_of_interest"];
    }
    else {
        self.locationTitleView.text = [NSString stringWithFormat:@"%@ %@", [address objectForKey:@"street_number"], [address objectForKey:@"route"]];
    }
    
    self.locationSubtitleView.text = [NSString stringWithFormat:@"%@, %@", [address objectForKey:@"neighborhood"], [address objectForKey:@"locality"]];

    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.selectedLocation.coordinate.latitude
                                                            longitude:self.selectedLocation.coordinate.longitude
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,
                                                   PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT * 2 + PLACE_TEXT_MARGIN_BOTTOM + 1,
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height - PLACE_TEXT_MARGIN_TOP - PLACE_TEXT_HEIGHT * 2 - PLACE_TEXT_MARGIN_BOTTOM - 1)
                                 camera:camera];
    mapView_.myLocationEnabled = YES;

    [self.view addSubview:mapView_];

    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = (UIControl *)self.view;
	
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + PLACE_TEXT_MARGIN_LEFT,
                                                                   self.view.bounds.origin.y + PLACE_TEXT_MARGIN_TOP,
                                                                   self.view.bounds.size.width - PLACE_TEXT_MARGIN_LEFT - PLACE_TEXT_MARGIN_RIGHT,
                                                                   PLACE_TEXT_HEIGHT)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    titleLabel.textColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.locationTitleView = titleLabel;
    [self.view addSubview:self.locationTitleView];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + PLACE_TEXT_MARGIN_LEFT,
                                                                    self.view.bounds.origin.y + PLACE_TEXT_MARGIN_TOP + self.locationTitleView.bounds.size.height,
                                                                    self.view.bounds.size.width - PLACE_TEXT_MARGIN_LEFT - PLACE_TEXT_MARGIN_RIGHT,
                                                                    PLACE_TEXT_HEIGHT)];
    subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    subtitleLabel.textColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    self.locationSubtitleView = subtitleLabel;
    [self.view addSubview:self.locationSubtitleView];
    
    UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-enabled.png"]];
    locationIcon.frame = CGRectMake((PLACE_TEXT_MARGIN_LEFT - ICON_WIDTH)/2,
                                    ((PLACE_TEXT_MARGIN_TOP*2 + PLACE_TEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
                                    ICON_WIDTH,
                                    ICON_HEIGHT);
    [self.view addSubview:locationIcon];
    
    UIView *dividerLine = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                   PLACE_TEXT_MARGIN_TOP + 2*PLACE_TEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM,
                                                                   self.view.bounds.size.width,
                                                                   0.5)];
    dividerLine.backgroundColor = [UIColor blackColor];
    dividerLine.alpha = 0.1;
    [self.view addSubview:dividerLine];
    
    dividerLine = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                           PLACE_TEXT_MARGIN_TOP + 2*PLACE_TEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 0.5,
                                                           self.view.bounds.size.width,
                                                           0.5)];
    dividerLine.backgroundColor = [UIColor whiteColor];
    dividerLine.alpha = 0.1;
    [self.view addSubview:dividerLine];
    
    UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    UIImageView *innerShadowView = [[UIImageView alloc] initWithImage:innerShadow];
    innerShadowView.frame = self.view.bounds;
    [self.view addSubview:innerShadowView];
    
    [self startStandardUpdates];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
