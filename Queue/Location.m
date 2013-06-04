//
//  Location.m
//  Queue
//
//  Created by Jeremy Lubin on 6/2/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "Location.h"
#import "Meeting.h"


@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic streetAddress;
@dynamic route;
@dynamic neighborhood;
@dynamic locality;
@dynamic name;
@dynamic country;
@dynamic imageURL;
@dynamic formattedAddress;
@dynamic meeting;

// -------------------------------------------------------------
// Populate a location with data from another location object
// but without its relationships
// -------------------------------------------------------------
- (void)populateWithLocation:(Location *)location
{
    self.latitude = [location.latitude copy];
    self.longitude = [location.longitude copy];
    self.streetAddress = [location.streetAddress copy];
    self.route = [location.route copy];
    self.neighborhood = [location.neighborhood copy];
    self.locality = [location.locality copy];
    self.name = [location.name copy];
    self.country = [location.country copy];
    self.imageURL = [location.imageURL copy];
    self.formattedAddress = [location.formattedAddress copy];
}

// -------------------------------------------------------------
// Populate a location with data returned from the Google
// reverse geocode service
// -------------------------------------------------------------
- (void)populateWithGoogleReverseGeocodeResult:(NSDictionary *)result
{
    // Loop through the first location returned to parse all of the address components we want to save
    NSArray *address = [result objectForKey:@"address_components"];
    NSMutableDictionary *addressComponents = [NSMutableDictionary dictionaryWithCapacity:5];
    
    for (NSDictionary *component in address)
    {
        NSArray *types = [component objectForKey:@"types"];
        NSString *name = [component objectForKey:@"long_name"];
        NSArray *keys = @[@"street_number", @"route", @"neighborhood", @"locality", @"point_of_interest", @"country"];
        
        for (NSString *key in keys)
        {
            if ([types containsObject:key])
                [addressComponents setObject:name forKey:key];
        }
        
        for (NSString *key in keys)
        {
            if (![addressComponents objectForKey:key])
                [addressComponents setObject:@"" forKey:key];
        }
    }
    
    self.latitude = [[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
    self.longitude = [[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
    self.streetAddress = [addressComponents objectForKey:@"street_number"];
    self.route = [addressComponents objectForKey:@"route"];
    self.neighborhood = [addressComponents objectForKey:@"neighborhood"];
    self.locality = [addressComponents objectForKey:@"locality"];
    self.name = [addressComponents objectForKey:@"point_of_interest"];
    self.country = [addressComponents objectForKey:@"country"]; 
}

// -------------------------------------------------------------
// Populate a location with data returned from the Google Places
// API
// -------------------------------------------------------------
- (void)populateWithGooglePlacesResult:(NSDictionary *)result
{
    self.name = [result objectForKey:@"name"];
    self.formattedAddress = [result objectForKey:@"formatted_address"] ? [result objectForKey:@"formatted_address"] : [result objectForKey:@"vicinity"];
    self.latitude = [NSNumber numberWithDouble:[[[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
    self.longitude = [NSNumber numberWithDouble:[[[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
}

// -------------------------------------------------------------
// Return an appropriate title for the location
// depending on the level of detail available
// -------------------------------------------------------------
- (NSString *)title
{
    if (![self.name isEqualToString:@""] && self.name)
        return self.name;
    else if (self.streetAddress && self.route)
        return [NSString stringWithFormat:@"%@ %@", self.streetAddress, self.route];
    else
        return self.neighborhood;
}

// -------------------------------------------------------------
// Return an appropriate subtitle for the location
// depending on the level of detail available
// -------------------------------------------------------------
- (NSString *)subtitle
{
    if (self.formattedAddress)
        return self.formattedAddress;
    else
        return self.locality;
}

@end
