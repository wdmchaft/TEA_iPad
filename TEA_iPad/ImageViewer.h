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

@interface ImageViewer : UIView <ContentViewerInterface> {
    
    UIImageView *imageViewer;
    BOOL contentSetFlag;
    
}

- (id)initWithFrame:(CGSize)size andImagePath:(NSString*) imagePath;

@end
