//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourImageHandler.h"
#import "TEA_iPadAppDelegate.h"
#import "BonjourService.h"
#import "LocalDatabase.h"
#import "LibraryImageItem.h"

@implementation BonjourImageHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeQuizImage;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    
    NSLog(@"**** image received");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *imageData = (NSData*) [aMessage.userData objectForKey:@"image"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imageName = [[aMessage.userData objectForKey:@"guid"] stringByAppendingString:@".png"]; 
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], imageName];
    
    LibraryImageItem *imageItem = [[[LibraryImageItem alloc] init] autorelease];
    imageItem.path = imageName;
    imageItem.name = [aMessage.userData objectForKey:@"name"];
    imageItem.guid = [aMessage.userData objectForKey:@"guid"];
    
    
    if([imageData writeToFile:imagePath atomically:YES])
    {
        [imageItem saveLibraryItem];
    }
        
    
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