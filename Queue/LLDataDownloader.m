//
//  LLDataDownloader.m
//  RideShare
//
//  Created by Jeremy Lubin on 11/10/11.
//  Copyright (c) 2011 New York University. All rights reserved.
//

#import "LLDataDownloader.h"

static NSString* const UserCookiesKey = @"UserCookies";
static NSString* const RootURL = @"http://carma.io";

@implementation LLDataDownloader

@synthesize receivedData;
@synthesize delegate;
@synthesize identifier;

// -------------------------------------------------------------
// Initiates API request for image data
// -------------------------------------------------------------

- (BOOL)getDataWithURL:(NSString *)url {
    
    // Initiate the VIN Provider connection
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Add cookies to the request header
    /*NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (id cookie in [storage cookiesForURL:[NSURL URLWithString:RootURL]])
    {
        [theRequest addValue:[cookie value] forHTTPHeaderField:@"Cookies"];
    }*/
    
    NSURLConnection *theConnection =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    //    NSLog(@"Setting up connection...");

    
    // Return NO if connection is unsuccessful, otherwise start downloading
	if (theConnection) {
		self.receivedData = [NSMutableData data];
//        NSLog(@"Connection Established");
		return YES;
	}
	else {
//        NSLog(@"Connection failed");
		return NO;
	}
    
}

- (BOOL)postDataWithURL:(NSString *)url andParams:(NSString *)params
{
    
    // Initiate the VIN Provider connection
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Set method to POST
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Add cookies to the request header
    /*NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
     
     for (id cookie in [storage cookiesForURL:[NSURL URLWithString:RootURL]])
     {
     [theRequest addValue:[cookie value] forHTTPHeaderField:@"Cookies"];
     }*/
    
    NSURLConnection *theConnection =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    //    NSLog(@"Setting up connection...");
    
    
    // Return NO if connection is unsuccessful, otherwise start downloading
	if (theConnection) {
		self.receivedData = [NSMutableData data];
        //        NSLog(@"Connection Established");
		return YES;
	}
	else {
        //        NSLog(@"Connection failed");
		return NO;
	} 
    
}

#pragma mark -
#pragma mark NSURLConnection Methods

// -------------------------------------------------------------
// These methods manage asynchronous downloading of data
// -------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
//	NSLog(@"Downloading data...");
    
    // Get cookies from resonse
    /*NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSDictionary *theHeaders = [httpResponse allHeaderFields];
    NSArray      *theCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:theHeaders forURL:[response URL]];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [storage setCookies:theCookies forURL:[NSURL URLWithString:RootURL] mainDocumentURL:nil];
    
    //[[NSUserDefaults standardUserDefaults] setObject:theCookies forKey:UserCookiesKey];*/
    
    
    
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
//    NSLog(@"Download failed with error %@",error);
    // Inform the delegate that image data failed to download
	if ([delegate respondsToSelector:@selector(dataHasFinishedDownloadingWithResult:andData:)])
		[delegate dataHasFinishedDownloadingWithResult:NO andData:nil];
    
    if ([delegate respondsToSelector:@selector(dataHasFinishedDownloadingForDownloader:withResult:andData:)]) {
        [delegate dataHasFinishedDownloadingForDownloader:self withResult:NO andData:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//	NSLog(@"Download successful!");
    // Send successfully downloaded image data    
    if ([delegate respondsToSelector:@selector(dataHasFinishedDownloadingWithResult:andData:)])
		[delegate dataHasFinishedDownloadingWithResult:YES andData:receivedData];
    
    if ([delegate respondsToSelector:@selector(dataHasFinishedDownloadingForDownloader:withResult:andData:)]) {
        [delegate dataHasFinishedDownloadingForDownloader:self withResult:YES andData:receivedData];
    }
    
}

@end
