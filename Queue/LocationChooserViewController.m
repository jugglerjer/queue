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
#import "Meeting.h"
#import "Location.h"


#define PLACE_TEXT_MARGIN_LEFT       48
#define PLACE_TEXT_MARGIN_RIGHT      48
#define PLACE_TEXT_MARGIN_TOP        14
#define PLACE_TEXT_MARGIN_BOTTOM     14
#define PLACE_TEXT_HEIGHT            18
#define PLACE_SUBTEXT_HEIGHT         15

#define ICON_HEIGHT                  18
#define ICON_WIDTH                   18

#define CLEAR_BUTTON_HEIGHT          22
#define CLEAR_BUTTON_WIDTH           22

#define kCurrentLocationDownloader    0
#define kDefaultLocationsDownloader   1
#define kSearchLocationsDownloader    2

@interface LocationChooserViewController ()

@property (strong, nonatomic) UITextField *locationTitleView;
@property (strong, nonatomic) UILabel *locationSubtitleView;
@property (strong, nonatomic) UITableView *searchResultsTable;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;
@property (strong, nonatomic) NSMutableArray *locationsToClear;
@property (strong, nonatomic) UIImageView *modeIconView;
@property (strong, nonatomic) UIButton *clearButton;
@property BOOL isLocationEnabled;
@property BOOL isActive;

@end

@implementation LocationChooserViewController

static CGFloat keyboardHeight = 216;
GMSMapView *mapView_;
static NSString *const googleGeocodeURL =  @"https://maps.googleapis.com/maps/api/geocode/json?";
static NSString *const googlePlacesTextSearchURL = @"https://maps.googleapis.com/maps/api/place/textsearch/json?key=AIzaSyDJk6VmHmcNveBQjDV91rJ3U4ExV0b4vIc";
static NSString *const googlePlacesNearbySearchURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDJk6VmHmcNveBQjDV91rJ3U4ExV0b4vIc";

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
        downloader.identifier = kCurrentLocationDownloader;
        NSString *url = [NSString stringWithFormat:@"%@latlng=%f,%f&sensor=true", googleGeocodeURL, location.coordinate.latitude, location.coordinate.longitude];
        [downloader getDataWithURL:url];
        self.location.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        self.location.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    }
}

// Perform search for the location that the user entered
- (void)performSearchWithDefaultLocation:(BOOL)defaultLocation
{
    LLDataDownloader *downloader = [[LLDataDownloader alloc] init];
    downloader.delegate = self;
    
    if (defaultLocation)
        downloader.identifier = kDefaultLocationsDownloader;
    else
        downloader.identifier = kSearchLocationsDownloader;
    
    NSString *query = [self.locationTitleView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url;
    if ([query isEqualToString:@""] || nil == query)
        url = [NSString stringWithFormat:@"%@&location=%f,%f&radius=1000&sensor=true",
                         googlePlacesNearbySearchURL,
                         [self.location.latitude doubleValue],
                         [self.location.longitude doubleValue]];
    else
        url = [NSString stringWithFormat:@"%@&query=%@&location=%f,%f&radius=1000&sensor=true",
                     googlePlacesTextSearchURL,
                     query,
                     [self.location.latitude doubleValue],
                     [self.location.longitude doubleValue]];
    [downloader getDataWithURL:url];
}

// Receive reverse geocode events from Google so we can display the user's location in a human-readable format
- (void)dataHasFinishedDownloadingForDownloader:(LLDataDownloader *)downloader withResult:(BOOL)result andData:(NSData *)data
{
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *locations = [jsonParser objectWithString:responseString];
    
    if (downloader.identifier == kCurrentLocationDownloader)
    {        
        // Create a location object for the returned location
        Location *newLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                  inManagedObjectContext:_managedObjectContext];
        [newLocation populateWithGoogleReverseGeocodeResult:[[locations objectForKey:@"results"] objectAtIndex:0]];
        
        // Initiate the search results array with the user's current location
        self.searchResultsArray = [NSMutableArray arrayWithArray:@[newLocation]];
        [self.searchResultsTable reloadData];
        if (!self.meeting.location)
            [self updateMapWithMarker:NO];        
        
        // Populate the table with nearby locations
        // that may be of interest to the user
        [self performSearchWithDefaultLocation:YES];
    }
    else
    {
        // Parse the Place API results as Location objects
        NSMutableArray *places = [NSMutableArray arrayWithCapacity:[[locations objectForKey:@"results"] count]];
        for (NSDictionary *location in [locations objectForKey:@"results"])
        {
            Location *newLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                              inManagedObjectContext:_managedObjectContext];
            [newLocation populateWithGooglePlacesResult:location];
            [places addObject:newLocation];
        }
        
        // If this is the default initial download,
        // add the results to the user's current location
        if (downloader.identifier == kDefaultLocationsDownloader)
            [self.searchResultsArray addObjectsFromArray:places];
        
        // If this is a set of user-initiated search results,
        // replace the existing location array with the results
        if (downloader.identifier == kSearchLocationsDownloader)
            self.searchResultsArray = places;
        
        [self.searchResultsTable reloadData];
    }
    
    if (self.locationsToClear)
        [self.locationsToClear addObjectsFromArray:self.searchResultsArray];
    else
        self.locationsToClear = [NSMutableArray arrayWithArray:self.searchResultsArray];
}

- (void)displayMeetingLocation
{
    self.locationTitleView.text = [self.location title];
    self.locationSubtitleView.text = [self.location subtitle];
    [self updateMapWithMarker:YES];
}

- (void)updateMapWithMarker:(BOOL)marker
{
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.location.latitude doubleValue]
                                                            longitude:[self.location.longitude doubleValue]
                                                                 zoom:15];
//    [mapView_ setCamera:camera];
    [mapView_ animateToCameraPosition:camera];
    
    [mapView_ clear];
    
    // Creates a marker in the center of the map.
    if (marker)
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        marker.title = [self.location title];
        marker.snippet = [self.location subtitle];
        marker.map = mapView_;
    }
}

- (void)updateLocationViewMode:(LocationChooserViewMode)mode
{
    // Generate a string for the image that corresponds to the chosen view mode
    NSString *iconName;
    switch (mode) {
        case LocationChooserViewModeLocationEnabled:
            iconName = @"location-enabled.png";
            break;
            
        case LocationChooserViewModeLocationDisabled:
            iconName = @"location-disabled.png";
            break;
            
        case LocationChooserViewModeLocationSearch:
            iconName = @"location-search.png";
            break;
            
        default:
            iconName = @"location-disabled.png";
            break;
    }
    
    // Create an image for the new icon
    UIImage *iconImage = [UIImage imageNamed:iconName];
    
    // Assign the image to our icon image view
    self.modeIconView.image = iconImage;
}

- (void)changeViewState
{
    if (self.isActive) {
        if ([_delegate respondsToSelector:@selector(locationChooserShouldBecomeInactive:)])
            [_delegate locationChooserShouldBecomeInactive:self];
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(locationChooserShouldBecomeActive:)])
            [_delegate locationChooserShouldBecomeActive:self];
    }
}

- (void)activateWithAnimation:(BOOL)animation
{    
    [self.clearButton setImage:[UIImage imageNamed:@"cancel-button-dark.png"] forState:UIControlStateNormal];
    [self.clearButton removeTarget:self action:@selector(clearLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(changeViewState) forControlEvents:UIControlEventTouchUpInside];
    self.clearButton.hidden = NO;
    
    CGRect searchFieldFrame = self.locationTitleView.frame;
    searchFieldFrame.origin.y = ((PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM) - PLACE_TEXT_HEIGHT) / 2;
    
    CGRect searchResultsFrame = self.searchResultsTable.frame;
    searchResultsFrame.origin.y = PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 1;
    searchResultsFrame.size.height = self.view.frame.size.height - searchResultsFrame.origin.y;
    
    [self updateLocationViewMode:LocationChooserViewModeLocationSearch];
    
    [self.locationTitleView becomeFirstResponder];
    
    double duration;
    if (animation) duration = 0.25;
    else duration = 0.0;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         // Remove the detail text label
                         // Slide the main text label down
                         // so the user can begin to use it
                         // as a search field
                         self.locationSubtitleView.alpha = 0;
                         self.locationTitleView.frame = searchFieldFrame;
                         self.searchResultsTable.frame = searchResultsFrame;
                     } completion:^(BOOL finished){
                         self.isActive = YES;
                         self.locationTitleView.text = @"";
                         self.locationTitleView.placeholder = @"Where did you meet up?";
                     }];
}

- (void)resignWithAnimation:(BOOL)animation
{    
    [self.clearButton setImage:[UIImage imageNamed:@"clear-button.png"] forState:UIControlStateNormal];
    [self.clearButton removeTarget:self action:@selector(changeViewState) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(clearLocation) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = self.locationTitleView.frame;
    if (self.isLocationEnabled) {
        frame.origin.y = PLACE_TEXT_MARGIN_TOP;
        self.clearButton.hidden = NO;
    }
    else {
        frame.origin.y = ((PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM) - PLACE_TEXT_HEIGHT) / 2;
        self.locationTitleView.text = @"";
        self.locationSubtitleView.text = @"";
        self.clearButton.hidden = YES;
    }
    
    CGRect searchResultsFrame = CGRectMake(0,
                                           PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 2 + keyboardHeight,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height - (PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 2 + keyboardHeight));
    
    if (self.isLocationEnabled)
        [self updateLocationViewMode:LocationChooserViewModeLocationEnabled];
    else
        [self updateLocationViewMode:LocationChooserViewModeLocationDisabled];
    
    [self.locationTitleView resignFirstResponder];
    
    double duration;
    if (animation) duration = 0.25;
    else duration = 0.0;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         // Add back the detail text label
                         // Slide the main text label up
                         // so that it no longer looks like a search field
                         if (self.isLocationEnabled)
                             self.locationSubtitleView.alpha = 1;
                         
                         self.locationTitleView.frame = frame;
                         self.searchResultsTable.frame = searchResultsFrame;
                     } completion:^(BOOL finished){
                         self.isActive = NO;
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIControl *controlView = [[UIControl alloc] initWithFrame:self.view.frame];
    [controlView addTarget:self action:@selector(changeViewState) forControlEvents:UIControlEventTouchUpInside];
    self.view = controlView;
	
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"queue_background.png"]];
    
    UITextField *titleLabel = [[UITextField alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + PLACE_TEXT_MARGIN_LEFT,
                                                                   ((PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM) - PLACE_TEXT_HEIGHT) / 2,
                                                                   self.view.bounds.size.width - PLACE_TEXT_MARGIN_LEFT - PLACE_TEXT_MARGIN_RIGHT,
                                                                   PLACE_TEXT_HEIGHT)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    titleLabel.textColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.delegate = self;
    titleLabel.placeholder = @"Where did you meet up?";
    [titleLabel addTarget:self action:@selector(textFieldWasEdited:) forControlEvents:UIControlEventEditingChanged];
    self.locationTitleView = titleLabel;
    [self.view addSubview:self.locationTitleView];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + PLACE_TEXT_MARGIN_LEFT,
                                                                    self.view.bounds.origin.y + PLACE_TEXT_MARGIN_TOP + self.locationTitleView.bounds.size.height,
                                                                    self.view.bounds.size.width - PLACE_TEXT_MARGIN_LEFT - PLACE_TEXT_MARGIN_RIGHT,
                                                                    PLACE_SUBTEXT_HEIGHT)];
    subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    subtitleLabel.textColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.alpha = 0;
    self.locationSubtitleView = subtitleLabel;
    [self.view addSubview:self.locationSubtitleView];
    
    CGRect iconFrame = CGRectMake((PLACE_TEXT_MARGIN_LEFT - ICON_WIDTH)/2,
                                    ((PLACE_TEXT_MARGIN_TOP + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM) - ICON_HEIGHT)/2,
                                    ICON_WIDTH,
                                    ICON_HEIGHT);
    UIImageView *locationIcon = [[UIImageView alloc] initWithFrame:iconFrame];
    self.modeIconView = locationIcon;
    [self updateLocationViewMode:LocationChooserViewModeLocationDisabled];
    [self.view addSubview:self.modeIconView];
    
    CGRect clearButtonFrame = CGRectMake(self.view.frame.size.width - (PLACE_TEXT_MARGIN_RIGHT - CLEAR_BUTTON_WIDTH)/2 - CLEAR_BUTTON_WIDTH,
                                         ((PLACE_TEXT_MARGIN_TOP + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM) - CLEAR_BUTTON_HEIGHT)/2,
                                         CLEAR_BUTTON_WIDTH,
                                         CLEAR_BUTTON_HEIGHT);
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = clearButtonFrame;
    [clearButton setImage:[UIImage imageNamed:@"clear-button.png"] forState:UIControlStateNormal];
    clearButton.contentMode = UIViewContentModeCenter;
    [clearButton addTarget:self action:@selector(clearLocation) forControlEvents:UIControlEventTouchUpInside];
    self.clearButton = clearButton;
    if (!self.meeting.location)
        self.clearButton.hidden = YES;
    [self.view addSubview:self.clearButton];
    
    UIView *dividerLine = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                   PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM,
                                                                   self.view.bounds.size.width,
                                                                   0.5)];
    dividerLine.backgroundColor = [UIColor blackColor];
    dividerLine.alpha = 0.1;
    [self.view addSubview:dividerLine];
    
    dividerLine = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                           PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 0.5,
                                                           self.view.bounds.size.width,
                                                           0.5)];
    dividerLine.backgroundColor = [UIColor whiteColor];
    dividerLine.alpha = 0.1;
    [self.view addSubview:dividerLine];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,
                                                   PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 1,
                                                   self.view.frame.size.width,
                                                   keyboardHeight)
                                 camera:nil];
    mapView_.myLocationEnabled = YES;
    
    [self.view addSubview:mapView_];
    
    CGRect searchResultsFrame = CGRectMake(0,
                                           PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 2 + keyboardHeight,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height - (PLACE_TEXT_MARGIN_TOP + PLACE_TEXT_HEIGHT + PLACE_SUBTEXT_HEIGHT + PLACE_TEXT_MARGIN_BOTTOM + 2 + keyboardHeight));
    UITableView *searchResultsTable = [[UITableView alloc] initWithFrame:searchResultsFrame style:UITableViewStylePlain];
    searchResultsTable.dataSource = self;
    searchResultsTable.delegate = self;
    self.searchResultsTable = searchResultsTable;
    [self.view addSubview:self.searchResultsTable];
    
    UIImage *innerShadow = [[UIImage imageNamed:@"timeline-inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    UIImageView *innerShadowView = [[UIImageView alloc] initWithImage:innerShadow];
    innerShadowView.frame = self.view.bounds;
    [self.view addSubview:innerShadowView];
    
    // Check whether a location already exists
    // If not, create a new one
    self.location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                              inManagedObjectContext:_managedObjectContext];
    if (self.meeting.location)
    {
        self.isLocationEnabled = YES;
        [self.location populateWithLocation:self.meeting.location];
        [self displayMeetingLocation];
        [self performSearchWithDefaultLocation:YES];
        [self resignWithAnimation:NO];
    }
    
    [self startStandardUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearLocations
{
    // Delete all of the non-chosen locations from the managed object context
    for (Location *location in self.locationsToClear)
    {
        if (![location isEqual:self.location])
            [_managedObjectContext deleteObject:location];
    }
}

- (void)clearLocation
{
    self.isLocationEnabled = NO;
    
    if ([_delegate respondsToSelector:@selector(locationChooser:didRemoveLocation:forMeeting:)])
    {
        [_delegate locationChooser:self didRemoveLocation:self.location forMeeting:self.meeting];
    }
    
    [self startStandardUpdates];
    [self resignWithAnimation:YES];
}

#pragma mark - Search Result Management Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(locationChooserShouldBecomeActive:)])
        [_delegate locationChooserShouldBecomeActive:self];
}

- (void)textFieldWasEdited:(UITextField *)sender
{
    [self performSearchWithDefaultLocation:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *LocationRowIdentifier = @"LocationRowIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LocationRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:LocationRowIdentifier];
    }
    
    Location *location = [self.searchResultsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [location title];
    cell.detailTextLabel.text = [location subtitle];
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.searchResultsTable)
    {
        [self.locationTitleView resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.location = [self.searchResultsArray objectAtIndex:indexPath.row];
    self.isLocationEnabled = YES;
    [self displayMeetingLocation];
    [self resignWithAnimation:YES];
    if ([_delegate respondsToSelector:@selector(locationChooser:didSelectLocation:forMeeting:)])
    {
        [_delegate locationChooser:self didSelectLocation:self.location forMeeting:self.meeting];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
