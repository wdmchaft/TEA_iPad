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
}

@property (assign) int currentMinute;
@property (assign) int currentSecond;
@property (assign) id target;
@property (assign) SEL selectorMethod;

- (void) startTimer;
- (void) stopTimer;

@end
