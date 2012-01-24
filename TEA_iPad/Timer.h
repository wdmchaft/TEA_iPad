//
//  Timer.h
//  TEA_iPad
//
//  Created by Oguz Demir on 26/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Timer : UIView 
{
    int currentMinute;
    int currentSecond;
    NSTimer *timer;
    
    id target;
    SEL selectorMethod;
    BOOL paused;
    BOOL runForward;
}

@property (nonatomic, assign) int currentMinute;
@property (nonatomic, assign) int currentSecond;
@property (nonatomic, retain) NSTimer *timer;
@property (assign) id target;
@property (assign) BOOL paused;
@property (assign) SEL selectorMethod;
@property (assign) BOOL runForward;

- (void) startTimer;
- (void) stopTimer;

@end
