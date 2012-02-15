//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourUpdateSessionHandler.h"
#import "BonjourService.h"
#import "TEA_iPadAppDelegate.h"
#import "ConfigurationManager.h"
#import "LocalDatabase.h"

@implementation BonjourUpdateSessionHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeUpdateSessionInfo;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *sessionName = [aMessage.userData valueForKey:@"name"];
    NSString *sessionGuid = [aMessage.userData valueForKey:@"sessionGuid"];
    
    NSString *updateSQL = [NSString stringWithFormat:@"update session set name='%@' where session_guid = '%@'", sessionName, sessionGuid];
    
    [[LocalDatabase sharedInstance] executeQuery:updateSQL];
    
    [pool release];
}

@end
