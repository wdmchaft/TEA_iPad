//
//  Quiz.m
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "ImageViewer.h"
#import <QuartzCore/QuartzCore.h>

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

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView:self];
    
    if(!CGRectContainsPoint(imageViewer.frame, location))
    {
        [self removeFromSuperview];
    }
}

- (void)dealloc
{
    [imageViewer release];
    
    [super dealloc];
}


@end
