//
//  DWClientDataHandler.m
//  BonjourServer
//
//  Created by Oguz Demir on 28/6/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "TEA_iPadAppDelegate.h"
#import "LocalDatabase.h"

@implementation BonjouClientDataHandler
@synthesize _data, client;
- (id)init
{
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        readLength = 0;
        bonjourMessageHandlers = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (BonjourMessageHandler*) findMessageHandlerForMessage:(BonjourMessage*) aMessage
{
    BonjourMessageHandlerManager *handlerManager = [BonjourMessageHandlerManager sharedInstance];
    for(BonjourMessageHandler *handler in handlerManager.bonjourMessageHandlers)
    {
        if (handler.handlerMessageType == aMessage.messageType) 
        {
            return handler;
        }
    }
    
    return nil;
}


- (void) handleData
{
 
    while (_data && [_data length] > 44) // There is enough data
    {
        NSString *messageGuid = [[[NSString alloc] initWithData:[_data subdataWithRange:NSMakeRange(0, 36 )] encoding:NSASCIIStringEncoding ] autorelease];
        int typeBits = 0; [_data getBytes:&typeBits range:NSMakeRange(36, 4)];
        int lengthBits = 0; [_data getBytes:&lengthBits range:NSMakeRange(40, 4)];
        
        
        TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        
        if([_data length] < lengthBits + 44 )
        {
            [dictionary setValue:[NSNumber numberWithInt:lengthBits + 44] forKey:@"totalBytes"];
            [dictionary setValue:[NSNumber numberWithInt:[_data length]] forKey:@"bytes"];
    
            [appDelegate.viewController receivedContentBytes:dictionary];
            [dictionary release];
            break;
        }
        else {
            
            [dictionary setValue:[NSNumber numberWithInt:1] forKey:@"totalBytes"];
            [dictionary setValue:[NSNumber numberWithInt:1] forKey:@"bytes"];
            [appDelegate.viewController receivedContentBytes:dictionary];
            [dictionary release];
        }
        

        
        NSData *dictData = [_data subdataWithRange:NSMakeRange(44, lengthBits)];
        [_data replaceBytesInRange:NSMakeRange(0, lengthBits + 44 ) withBytes:NULL length:0]; //clean up data
        
        NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:dictData options:NSPropertyListImmutable format:nil error:nil];
        
        // init BonjourMessage
        BonjourMessage *message = [[BonjourMessage alloc] init];
        message.guid = messageGuid;
        message.messageType = typeBits;
        message.userData = dict;
        message.client = client;
        
        // save system message
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *convertedDate = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *messageInsert = [NSString stringWithFormat:@"insert into system_messages select '%@', '%@', '%d', '0'", messageGuid, convertedDate, typeBits];
   
        [[LocalDatabase sharedInstance] executeQuery:messageInsert];

        [dateFormatter release];
        
        BonjourMessageHandler *handler = [self findMessageHandlerForMessage:message];
        if(handler)
        {
            [NSThread detachNewThreadSelector:@selector(handleMessage:) toTarget:handler withObject:message];
        }
        [message release];

      }
    
}

- (void)dealloc {
    [bonjourMessageHandlers release];
  //  [client release];
    [_data release];
    [super dealloc];
}

@end
