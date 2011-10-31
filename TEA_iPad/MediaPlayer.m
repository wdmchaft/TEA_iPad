//
//  Quiz.m
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "MediaPlayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation MediaPlayer

- (void) playbackStoped 
{
  //  [player stop];
    [self removeFromSuperview];
}

- (id)initWithFrame:(CGSize)size andVideoPath:(NSString*) videoPath
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
        
        
        NSURL *movieURL = [NSURL fileURLWithPath:videoPath];
        
        player = [[MPMoviePlayerController alloc] initWithContentURL: movieURL];
      
        [player.view setFrame: CGRectMake((1024 - size.width) / 2, (768 - size.height) / 2, size.width, size.height)];
        [self addSubview: player.view];
        
        [player.view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [player.view.layer setBorderWidth:2];
        [player.view.layer setCornerRadius:3];
        [player.view.layer setMasksToBounds:YES];
        
        [player play];
        
    }
    
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView:self];
    
    if(!CGRectContainsPoint(player.view.frame, location))
    {
        [player stop];
        [self playbackStoped];
    }
}

- (void)dealloc
{
    NSLog(@"player released");
    [player release];
    player = nil;
    
    [player stop];
    
    [super dealloc];
}


@end
