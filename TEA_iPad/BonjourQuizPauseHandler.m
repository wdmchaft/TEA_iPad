//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourQuizPauseHandler.h"
#import "TEA_iPadAppDelegate.h"
#import "BonjourService.h"

@implementation BonjourQuizPauseHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypePauseQuiz;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    Quiz *currentQuizWindow = appDelegate.currentQuizWindow;
    
    [currentQuizWindow pauseTimer];
   
    [pool release];
}

@end


/*
 
 else if(groupTypeBits == kDataGroupQuizAnswer)
 {
 
 long longData = 0; 
 @synchronized(client.dataCollector.data)
 {
 [client.dataCollector.data getBytes:&longData range:NSMakeRange(7, lengthBits)];
 }
 
 quiz.correctAnswer = longData;
 [quiz updateCorrectAnswer];
 
 }
 else if(groupTypeBits == kDataGroupQuizEnded)
 {
 //?    
 [quiz release];
 quiz = nil;
 quizMode = NO;
 }
 else if(groupTypeBits == kDataGroupQuizSolveTime)
 {
 int solveTime = 0;
 @synchronized(client.dataCollector.data)
 {
 [client.dataCollector.data getBytes:&solveTime range:NSMakeRange(7, lengthBits)];
 }
 
 
 quiz.solveTime = solveTime;
 
 TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
 
 //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
 
 [appDelegate performSelectorOnMainThread:@selector(showQuizWindow:) withObject:quiz waitUntilDone:NO];
 //[appDelegate showQuizWindow:quiz];
 }

 
 */