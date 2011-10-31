//
//  BonjourServer.h
//  tea
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPServer.h"
#import "ConfigurationManager.h"

@class DWDevice, BonjourMessage, BonjourClient;
@interface BonjourServer : NSObject <TCPServerDelegate>
{
    NSMutableArray *clients;
    TCPServer *server;
}

@property (retain) IBOutlet NSMutableArray *clients;
@property (retain) TCPServer *server;

- (void) startService;
- (BOOL) isDeviceConnectedToTheService:(DWDevice*) pDevice;

- (void) sendBonjourMessage:(BonjourMessage*) aMessage toClient:(BonjourClient*) aClient;
- (void) sendBonjourMessageToAllClients:(BonjourMessage*) aMessage;

@end
