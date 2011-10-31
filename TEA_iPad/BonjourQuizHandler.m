//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourQuizHandler.h"
#import "TEA_iPadAppDelegate.h"
#import "BonjourService.h"

@implementation BonjourQuizHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeQuiz;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    Quiz *quiz = [[Quiz alloc] initWithNibName:@"Quiz" bundle:nil];
    quiz.guid = [aMessage.userData valueForKey:@"guid"];
    quiz.solveTime = [[aMessage.userData valueForKey:@"solveTime"] intValue];
    
   // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   // NSString *imageName = @"test.png"; 
   // NSString *imagePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], imageName];
    
//    NSData *imageData = (NSData*) [aMessage.userData objectForKey:@"image"];
    //[imageData writeToFile:@"/test.png" atomically:YES];
    
    UIImage *image = [UIImage imageWithData:[aMessage.userData objectForKey:@"image"]];
    quiz.image = image;
    
    [appDelegate performSelectorOnMainThread:@selector(showQuizWindow:) withObject:quiz waitUntilDone:NO];
    
    
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