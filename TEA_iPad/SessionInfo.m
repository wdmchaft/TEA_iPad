//
//  SessionInfo.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "SessionInfo.h"
#import "TEA_iPadAppDelegate.h"

@implementation SessionInfo


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    switch (currentDisplayState) 
    {
        case kDisplayStateSessionName:
            sessionInfoLabel.text = appDelegate.session.sessionName;
            currentDisplayState = kDisplayStateSessionDate;
            break;
        case kDisplayStateSessionDate:
            sessionInfoLabel.text = appDelegate.session.dateInfo;
            currentDisplayState = kDisplayStateSessionTeacherName;
            
            break;
        case kDisplayStateSessionTeacherName:
            sessionInfoLabel.text = appDelegate.session.sessionTeacherName;
            currentDisplayState = kDisplayStateSessionName;
            break;   
        default:
            break;
    }
    

    [UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration: 1.5];  
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];  
    [UIView setAnimationBeginsFromCurrentState:YES];  
    sessionInfoLabel.alpha = 1.0; 
    [UIView commitAnimations]; 
}

- (void) sessionTimerTick
{

    [UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration: 1.5];  
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];  
    [UIView setAnimationBeginsFromCurrentState:YES];  
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    sessionInfoLabel.alpha = 0.0; 
    [UIView commitAnimations]; 
}

- (void) initSessionInfoView
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    sessionInfoLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [sessionInfoLabel setBackgroundColor:[UIColor clearColor]];
    [sessionInfoLabel setTextColor:[UIColor whiteColor]];
    [sessionInfoLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [sessionInfoLabel setTextAlignment:UITextAlignmentLeft];
    [self addSubview:sessionInfoLabel];
    
    sessionInfoTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(sessionTimerTick) userInfo:nil repeats:YES];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self initSessionInfoView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self initSessionInfoView];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [sessionInfoTimer invalidate];
    [sessionInfoLabel release];
    [super dealloc];
}

@end
