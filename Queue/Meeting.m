//
//  Meeting.m
//  Queue
//
//  Created by Jeremy Lubin on 6/2/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "Meeting.h"
#import "Contact.h"
#import "Location.h"
#import "SBJSON.h"
#import "LLDataDownloader.h"

static NSString *const googlePlacesTextSearchURL = @"https://maps.googleapis.com/maps/api/place/textsearch/json?key=AIzaSyDJk6VmHmcNveBQjDV91rJ3U4ExV0b4vIc";

@implementation Meeting

@dynamic salesforceID;
@dynamic date;
@dynamic method;
@dynamic note;
@dynamic contact;
@dynamic location;

// ------------------------
// Convert the meeting method
// into a string and save it
// to the object
// ------------------------
//- (void)setMeetingMethod:(MeetingMethod)method
//{
//    switch (method) {
//        case MeetingMethodQueue:
//            self.method = @"queue";
//            break;
//        case MeetingMethodSnooze:
//            self.method = @"snooze"
//            
//        default:
//            break;
//    }
//}

- (void)populateWithSalesforceEvent:(NSDictionary *)event
{
    // Create a date object given the salesforce formatting
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-MM-dd"];
    self.date = [formatter dateFromString:[event objectForKey:@"ActivityDate"]];
    self.salesforceID = [event objectForKey:@"Id"];
    self.note = [event objectForKey:@"Description"];
    [self setLocationWithSearchTerm:[event objectForKey:@"Location"]];
}

- (void)setLocationWithSearchTerm:(NSString *)searchTerm
{
    // Call the Google Places API with the search term
    LLDataDownloader *downloader = [[LLDataDownloader alloc] init];
    downloader.delegate = self;
    NSString *query = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"%@&query=%@&sensor=true",
                     googlePlacesTextSearchURL,
                     query];
    [downloader getDataWithURL:url];
}

- (void)dataHasFinishedDownloadingForDownloader:(LLDataDownloader *)downloader withResult:(BOOL)result andData:(NSData *)data
{
    // Parse Google Places results
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *locations = [jsonParser objectWithString:responseString];
    NSMutableArray *places = [NSMutableArray arrayWithCapacity:[[locations objectForKey:@"results"] count]];

    // Take the first result and creating a meeting location with it
    Location *newLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                      inManagedObjectContext:self.managedObjectContext];
    [newLocation populateWithGooglePlacesResult:[places objectAtIndex:0]];
    self.location = newLocation;
    
    // Notifiy the app that a meeting has been updated
}

@end
