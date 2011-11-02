//
//  Quiz.m
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LockScreen.h"
#import <QuartzCore/QuartzCore.h>

@implementation LockScreen


- (id)init
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
        
        UIImage *lockImage = [UIImage imageNamed:@"LockScreen.png"];
        imageViewer = [[UIImageView alloc] initWithImage:lockImage];
        [imageViewer setContentMode:UIViewContentModeScaleAspectFit];
        [imageViewer setFrame: CGRectMake((1024 - lockImage.size.width) / 2, (768 - lockImage.size.height) / 2, lockImage.size.width, lockImage.size.height)];
        [self addSubview: imageViewer];
        [imageViewer setBackgroundColor:[UIColor clearColor]]; 
    }
    
    return self;
}



- (void)dealloc
{
    [imageViewer release];
    
    [super dealloc];
}


@end
