//
//  ContactImageView.m
//  Queue
//
//  Created by Jeremy Lubin on 7/4/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "ContactImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"

@interface ContactImageView ()
{
    UIImage *gloss;
    UIImage *placeholder;
}
@end

@implementation ContactImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Create the image view
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self.layer setMinificationFilter:kCAFilterTrilinear];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 6;
        
        // Cache common images
        gloss = [UIImage imageNamed:@"avatar-gloss-small.png"];
        placeholder = [UIImage imageNamed:@"contact-avatar-placeholder-clean.png"];
    }
    return self;
}

// -----------------------------
// Draw a new image with gloss
// -----------------------------
- (UIImage *)imageWithGloss:(UIImage *)image
{
    if (!image)
        image = placeholder;
    
    UIImage *newImage = [image thumbnailImage:self.frame.size.height*2 transparentBorder:0 cornerRadius:self.layer.cornerRadius interpolationQuality:kCGInterpolationHigh];
//    UIImage *newGloss = [gloss thumbnailImage:self.frame.size.height transparentBorder:0 cornerRadius:self.layer.cornerRadius interpolationQuality:kCGInterpolationHigh];
    
    CGSize size = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [gloss drawAtPoint:CGPointZero];
    UIImage *imageWithGloss = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageWithGloss;
}

@end
