//
//  BonjourSessionInfoHandler.m
//  TEA_iPad
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourDocumentHandler.h"
#import "TEA_iPadAppDelegate.h"
#import "BonjourService.h"
#import "LocalDatabase.h"
#import "LibraryDocumentItem.h"

@implementation BonjourDocumentHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeDocument;
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *documentData = (NSData*) [aMessage.userData objectForKey:@"document"];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentName = [NSString stringWithFormat:@"%@.%@", [LocalDatabase stringWithUUID], [aMessage.userData objectForKey:@"extension"]];
    NSString *documentPath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], documentName];

    [documentData writeToFile:documentPath atomically:YES];
    
    LibraryDocumentItem *documentItem = [[LibraryDocumentItem alloc] init];
    [documentItem setName:[aMessage.userData objectForKey:@"name"]];
    [documentItem setPath:documentPath];
    
    [documentItem saveLibraryItem];
    
    
    [documentItem release];
    
    [pool release];
    
        
}

@end


/*
 
 NSData *documentData = nil;
 @synchronized(client.dataCollector.data)
 {
 documentData = [client.dataCollector.data subdataWithRange:NSMakeRange(7, lengthBits)];
 }
 
 NSLog(@"document size %d", [documentData length]);
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentName = [NSString stringWithFormat:@"%@.%@", [BonjouClientDataHandler stringWithUUID], documentItem.extension];
 NSString *documentPath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], documentName];
 [documentItem setPath:documentPath];
 [documentItem saveLibraryItem];
 [documentData writeToFile:documentPath atomically:YES];
 
 */