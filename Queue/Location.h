//
//  Location.h
//  Queue
//
//  Created by Jeremy Lubin on 6/2/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Meeting;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSString * route;
@property (nonatomic, retain) NSString * neighborhood;
@property (nonatomic, retain) NSString * locality;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) Meeting *meeting;

- (void)populateWithLocation:(Location *)location;
- (void)populateWithGoogleReverseGeocodeResult:(NSDictionary *)result;
- (void)populateWithGooglePlacesResult:(NSDictionary *)result;
- (NSString *)title;
- (NSString *)subtitle;

@end
