//
//  LLPullNavigationScrollView.m
//  Queue
//
//  Created by Jeremy Lubin on 6/8/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import "LLPullNavigationScrollView.h"
#import "LLPullNavigationTableView.h"

@implementation LLPullNavigationScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//    return YES;
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentLocation = [touch locationInView:self];
    CGPoint previousLocation = [touch previousLocationInView:self];
    if (previousLocation.y > currentLocation.y)
    {
        self.scrollEnabled = NO;
        [super touchesCancelled:touches withEvent:event];
    }
    else {
        self.scrollEnabled = YES;
        [self becomeFirstResponder];
        [super touchesMoved:touches withEvent:event];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded: touches withEvent: event];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
