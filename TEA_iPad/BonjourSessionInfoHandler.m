//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourSessionInfoHandler.h"
#import "BonjourService.h"
#import "TEA_iPadAppDelegate.h"
#import "ConfigurationManager.h"

@implementation BonjourSessionInfoHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeSessionInfo;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    if(aMessage.client)
        appDelegate.connectedHost = aMessage.client.hostName;
    appDelegate.session.sessionGuid = [aMessage.userData valueForKey:@"guid"];
    appDelegate.session.sessionName = [aMessage.userData valueForKey:@"name"];
    appDelegate.session.sessionLectureName = [aMessage.userData valueForKey:@"courseName"];
    appDelegate.session.sessionLectureGuid  = [aMessage.userData valueForKey:@"courseGuid"];
    appDelegate.session.sessionTeacherName = [aMessage.userData valueForKey:@"teacherName"];
    appDelegate.session.dateInfo = [aMessage.userData valueForKey:@"dateinfo"];
    
    appDelegate.session.quizPromptTitle = [aMessage.userData valueForKey:@"quizPromptTitle"];
    appDelegate.session.quizPromptBGColor = [aMessage.userData valueForKey:@"quizPromptBGColor"];
    appDelegate.session.quizPromptCancelTitle = [aMessage.userData valueForKey:@"quizPromptCancelTitle"];
    appDelegate.session.quizPromptOKTitle = [aMessage.userData valueForKey:@"quizPromptOKTitle"];
    appDelegate.session.quizPromptTextColor = [aMessage.userData valueForKey:@"quizPromptTextColor"];
    
    // Get configuration values from server.
    NSDictionary *iPadConfigDictionary = [aMessage.userData objectForKey:@"iPadConfig"];
    [ConfigurationManager setConfigurationValue:iPadConfigDictionary forKey:@"iPadConfig"];
    
    if(appDelegate.state != kAppStateSyncing)
    {
        appDelegate.state = kAppStateLogon;
    }
    
    [pool release];
}

@end
