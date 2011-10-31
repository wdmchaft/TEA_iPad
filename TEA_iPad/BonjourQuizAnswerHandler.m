//
//  BonjourDeviceInfoHandler.m
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "BonjourQuizAnswerHandler.h"
#import "LocalDatabase.h"
#import "LibraryView.h"
#import "TEA_iPadAppDelegate.h"

@implementation BonjourQuizAnswerHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeQuizAnswer;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    int answer =  [[aMessage.userData valueForKey:@"answer"] intValue];
    NSString *guid = [aMessage.userData valueForKey:@"guid"];
    
    
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db openDatabase];
    
    NSString *sql = [NSString stringWithFormat:@"update library set quizCorrectAnswer = '%d' where guid = '%@'", answer, guid];
    [db executeQuery:sql];
    
    [db closeDatabase];
    [db release];
    
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
    
    [pool release];
}

@end
