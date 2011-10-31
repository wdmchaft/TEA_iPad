//
//  BonjourMessageManager.m
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"


@implementation BonjourMessageHandlerManager
static BonjourMessageHandlerManager *sharedInstance;

@synthesize bonjourMessageHandlers;

- (id)init {
    self = [super init];
    if (self) {
        bonjourMessageHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (BonjourMessageHandlerManager*) sharedInstance
{
    if(!sharedInstance)
    {
        sharedInstance = [[BonjourMessageHandlerManager alloc] init];
    }
    return sharedInstance;
}

- (void)dealloc {
    [bonjourMessageHandlers release];
    [super dealloc];
}

@end
