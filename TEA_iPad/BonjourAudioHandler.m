//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourAudioHandler.h"
#import "TEA_iPadAppDelegate.h"
#import "BonjourService.h"
#import "LocalDatabase.h"
#import "LibraryAudioItem.h"

@implementation BonjourAudioHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeAudio;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *audioData = (NSData*) [aMessage.userData objectForKey:@"audio"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioName = [[aMessage.userData objectForKey:@"guid"] stringByAppendingString:@".mov"]; 
    NSString *audioPath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], audioName];
    
    LibraryAudioItem *audioItem = [[LibraryAudioItem alloc] init];
    audioItem.path = audioName;
    audioItem.name = [aMessage.userData objectForKey:@"name"];
    audioItem.guid = [aMessage.userData objectForKey:@"guid"];
    [audioItem saveLibraryItem];
    
    [audioData writeToFile:audioPath atomically:YES];
    [audioItem release];    
    
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