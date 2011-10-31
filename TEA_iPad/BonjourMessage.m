//
//  BonjourMessage.m
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"


@implementation BonjourMessage
@synthesize  messageType, userData, guid, client;


- (id) init
{
    self = [super init];
    
    if(self)
    {
        CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
        NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        self.guid = uuidString;
        [uuidString release];
        
        messageType = 0;
    }
    
    return self;
}

- (void) dealloc
{
    [client release];
    [guid release];
    [userData release];
    [super dealloc];
}

+ (NSData*) dataWithMessage:(BonjourMessage*) aMessage
{
    NSMutableData *dataValue = [[NSMutableData alloc] init];
    
    // Serialize user data
    NSData *_data = [NSPropertyListSerialization dataFromPropertyList:aMessage.userData format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];    
    uint32_t length = (uint32_t) [_data length];
    uint32_t type = (uint32_t) aMessage.messageType;
    
    
    
    [dataValue appendData:[aMessage.guid dataUsingEncoding:NSASCIIStringEncoding]];
    [dataValue appendData:[NSData dataWithBytes:(char *) &type length:sizeof(uint32_t)]];
    [dataValue appendData:[NSData dataWithBytes:(char *) &length length:sizeof(uint32_t)]];
    [dataValue appendData:_data];
    
    return [dataValue autorelease];
}

@end
