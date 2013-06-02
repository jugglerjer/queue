//
//  LLDataDownloader.h
//  RideShare
//
//  Created by Jeremy Lubin on 11/10/11.
//  Copyright (c) 2011 New York University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLDataDownloaderDelegate;

@interface LLDataDownloader : NSObject {
    
    NSMutableData *receivedData;
    id<LLDataDownloaderDelegate> delegate;
    int identifier;
    
}

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) id<LLDataDownloaderDelegate> delegate;
@property int identifier;

- (BOOL)getDataWithURL:(NSString *)url;
- (BOOL)postDataWithURL:(NSString *)ur andParams:(NSString *)params;

@end

@protocol LLDataDownloaderDelegate <NSObject>
@optional

/*!
 @method     dataHasFinishedDownloadingWithResult:andData:
 @abstract   Called to let the controller know that the data has finished downloading
 @discussion This method is called when the data has been downloaded successfully or an error occured in downloading
 
 @param      result              A boolean value indicating whether or not the data was downloaded
 @param      action              The downloaded information. This value is nil if the information did not download successfully.
 */
- (void)dataHasFinishedDownloadingWithResult:(BOOL)result andData:(NSData *)data; // Deprecated
- (void)dataHasFinishedDownloadingForDownloader:(LLDataDownloader *)downloader withResult:(BOOL)result andData:(NSData *)data;

@end
