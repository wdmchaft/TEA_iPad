//
//  SessionInfo.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

enum kDisplayState {
    kDisplayStateSessionName = 0,
    kDisplayStateSessionDate = 1,
    kDisplayStateSessionTeacherName = 2
    };


@interface SessionInfo : UIView 
{
    int currentDisplayState;
    UILabel *sessionInfoLabel;
    NSTimer *sessionInfoTimer;
}

@end
