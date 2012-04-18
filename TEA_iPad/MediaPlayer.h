//
//  Quiz.h
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ContentViewerInterface.h"

@interface MediaPlayer : UIView <ContentViewerInterface> {
    
    MPMoviePlayerController *player;
    BOOL contentSetFlag;
    
    NSString *guid;
    NSDate *currentTime;
    long activeTime;
}

@property (nonatomic, assign) long activeTime;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSDate *currentTime;


- (id)initWithFrame:(CGSize)size andVideoPath:(NSString*) videoPath;

@end
