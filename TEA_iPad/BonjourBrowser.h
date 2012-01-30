//
//  BonjourBrowser.h
//  TEA_iPad
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BonjourClient, BonjourMessage;

@interface BonjourBrowser : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, NSStreamDelegate> 
{
@private
    NSNetServiceBrowser *netServiceBrowser;
  //  NSNetService *service;
    //BonjourClient *client;
    
    NSMutableArray *clients;
    NSMutableArray *services;

}

@property (nonatomic, retain) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, assign) NSMutableArray *services;
//@property (nonatomic, retain) NSNetService *service;
//@property (nonatomic, retain) NSMutableArray *clients;

- (NSMutableArray*) bonjourServers;

- (void) restartBrowse;
- (void) startBrowse;
- (void) sendBonjourMessage:(BonjourMessage*) aMessage toClient:(BonjourClient*) aClient;
- (void) sendBonjourMessageToAllClients:(BonjourMessage*) aMessage;
@end
