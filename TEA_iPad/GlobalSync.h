//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalSync : UIView 
{
    UIProgressView *progressView;
    UILabel *progressLabel;
    int currentPhase;
    int phaseCount;
}

@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UILabel *progressLabel;
@property (nonatomic, assign) int currentPhase;

- (void) updateMessage:(NSString*) message;
- (void) updateProgress:(NSNumber*) progressValue;

@end
