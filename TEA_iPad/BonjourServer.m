//
//  BonjourServer.m
//  tea
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "ConfigurationManager.h"

@implementation BonjourServer
@synthesize clients, server;

- (id)init
{
    self = [super init];
    if (self) {
        clients = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    [server release];
    [clients release];
    [super dealloc];
}



- (void) startService
{
    NSError *error = nil;
    
    self.server = [[TCPServer new] autorelease];
    server.delegate = self;
	if(server == nil || ![server start:&error]) {
		if (error == nil) {
			NSLog(@"Failed creating server: Server instance is nil");
		} else {
            NSLog(@"Failed creating server: %@", error);
		}
		
		return;
	}
	
    NSString *serviceName = [ConfigurationManager getConfigurationValueForKey:@"BonjourServiceName"];
    
	if(![server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:serviceName] name:nil]) {
		
		return;
	}
}


- (void) serverDidEnableBonjour:(TCPServer *)server withName:(NSString *)string
{
	NSLog(@"server enabled %@", string);
    
}


- (void)didAcceptConnectionForServer:(TCPServer *)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	NSLog(@"server got connection");
    
    BonjourClient *client = [[BonjourClient alloc] init];
    
    client.inputStream = istr;
    client.outputStream = ostr;
    client.bonjourServer = self;
    [client openStreams];
    [clients addObject:client];
    [client release];
    
  //  [((teaAppDelegate *) [NSApp delegate]) publishSessionToClients];
}

- (BOOL) isDeviceConnectedToTheService:(DWDevice*) pDevice
{
    
    if(pDevice == (DWDevice*) [NSNull null])
    {
        return NO;
    }
    
    for(BonjourClient *client in clients)
    {
   //     if([client.deviceid isEqualToString:pDevice.device_id])
        {
            return YES;
        }
    }
    
    
    return NO;
}


- (void) publishSessionToClients
{
   // [((teaAppDelegate *) [NSApp delegate]) publishSessionToClients];
}

- (void) sendBonjourMessage:(BonjourMessage*) aMessage toClient:(BonjourClient*) aClient
{
    [aClient sendBonjourMessage:aMessage];
}


- (void) sendBonjourMessageToAllClients:(BonjourMessage*) aMessage 
{
    @try {
        for(BonjourClient *client in clients)
        {
            [self sendBonjourMessage:aMessage toClient:client];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"catch all client exception");
    }

    
}


@end

