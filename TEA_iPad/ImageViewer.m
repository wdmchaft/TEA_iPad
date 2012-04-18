//
//  Quiz.m
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "ImageViewer.h"
#import <QuartzCore/QuartzCore.h>
#import "TEA_iPadAppDelegate.h"

@implementation ImageViewer


- (id)initWithFrame:(CGSize)size andImagePath:(NSString*) imagePath
{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *bg = [[UIView alloc] initWithFrame:self.frame];
        [bg setBackgroundColor:[UIColor blackColor]];
        [bg setAlpha:0.5];
        [self addSubview:bg];
        [bg release];
        
        
        //NSURL *movieURL = [NSURL fileURLWithPath:videoPath];
        
        imageViewer = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        [imageViewer setContentMode:UIViewContentModeScaleAspectFit];
        [imageViewer setFrame: CGRectMake((1024 - size.width) / 2, (768 - size.height) / 2, size.width, size.height)];
        [self addSubview: imageViewer];
        [imageViewer setBackgroundColor:[UIColor grayColor]];
        [imageViewer.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [imageViewer.layer setBorderWidth:2];
        [imageViewer.layer setCornerRadius:3];
        [imageViewer.layer setMasksToBounds:YES];
        
    }
    
    return self;
}



- (void) closeFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self removeFromSuperview];
    if(contentSetFlag)
        ((TEA_iPadAppDelegate*) [[UIApplication sharedApplication]delegate]).viewController.displayingSessionContent = NO;

    [((TEA_iPadAppDelegate*) [[UIApplication sharedApplication]delegate]).viewController contentViewClosed:self];
}

- (void) closeContentViewWithDirection:(ContentViewOpenDirection)direction
{
    [self closeContentViewWithDirection:direction dontSetDisplayingContent:YES];
}


- (void) closeContentViewWithDirection:(ContentViewOpenDirection)direction dontSetDisplayingContent:(BOOL)setFlag
{
    contentSetFlag = setFlag;

    CGRect closeRect;
    if(direction == kContentViewOpenDirectionToLeft)
    {
        closeRect = CGRectMake(-self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionToRight)
    {
        closeRect = CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionNormal)
    {
        closeRect = self.frame;
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDidStopSelector:@selector(closeFinished:finished:context:)];
    
    self.frame = closeRect;
    
    [UIView commitAnimations];
    
    
}

- (void) loadContentView:(UIView *)view withDirection :(ContentViewOpenDirection)direction
{
   
    CGRect initialRect;
    if(direction == kContentViewOpenDirectionToLeft)
    {
        initialRect = CGRectMake(view.frame.size.width * 2, 0, view.frame.size.width, view.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionToRight)
    {
        initialRect = CGRectMake(- view.frame.size.width * 2, 0, view.frame.size.width, view.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionNormal)
    {
        initialRect = view.frame;
    }
    view.frame = initialRect;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    view.frame = CGRectMake(0, 0, 1024, 768);
    
    [UIView commitAnimations];
}






- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView:self];
    
    if(!CGRectContainsPoint(imageViewer.frame, location))
    {
        [self closeContentViewWithDirection:kContentViewOpenDirectionNormal];
    }
}

- (void)dealloc
{
    [imageViewer release];
    
    [super dealloc];
}


@end
