  //
//  BonjourBrowser.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourBrowser.h"
#import "TEA_iPadAppDelegate.h"
#import "BonjourService.h"
#import "ConfigurationManager.h"
#import "Quiz.h"

@implementation BonjourBrowser


@synthesize netServiceBrowser, services;

/*
- (void) sendData:(NSData *)dataValue groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType 
{
    
    
	if (output)
    {
        
        uint32_t length = (uint32_t) [dataValue length];
        
        NSMutableData *tmpData = [[[NSMutableData alloc] init] autorelease];
        [tmpData appendData:[NSData dataWithBytes:(char *) &groupCode length:1]];
        [tmpData appendData:[NSData dataWithBytes:(char *) &groupCodetype length:1]];
        [tmpData appendData:[NSData dataWithBytes:(char *) &dataType length:1]];
        [tmpData appendData:[NSData dataWithBytes:(char *) &length length:sizeof(uint32_t)]];
        [tmpData appendData:dataValue];
        
        int returnVal = [output write:(uint8_t *)[tmpData bytes] maxLength:[tmpData length]];
        NSLog(@"return val %d", returnVal);
    }
    
}
*/


- (NSMutableArray*) bonjourServers
{
    return clients;
}

/*
- (void) sendString:(NSString *)dataString groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType
{
    [self sendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]  groupCode:groupCode groupCodeType:groupCodetype dataType:dataType];
}

- (void) sendInt:(int)dataInt groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType
{
    [self sendData:[NSData dataWithBytes:&dataInt length:sizeof(int)]  groupCode:groupCode groupCodeType:groupCodetype dataType:dataType];
}

*/



- (id)init
{
    self = [super init];
    if (self) 
    {
        clients = [[NSMutableArray alloc] init];
        services = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)dealloc
{
    
    //   [service release];
    [netServiceBrowser stop];
    [netServiceBrowser release];
    [clients release];
    [services release];
    
    [super dealloc];
}

- (void) restartBrowse
{
    [clients release];
    //[service release];
    [netServiceBrowser stop];
    [netServiceBrowser release];
    [services removeAllObjects];
    
    self = [self init];
    
  /*  input.delegate = nil;
    [input release];
    input = nil;
    
    output.delegate = nil;
    [input release];
    input = nil;
    */
    
    [self startBrowse];
}

- (void) startBrowse
{
    
    self.netServiceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
    
    NSString *serviceName = [NSString stringWithFormat:@"_%@._tcp.", [ConfigurationManager getConfigurationValueForKey:@"BonjourServiceName"]];
    
    //serviceName = @"_teaservice._tcp.";
	netServiceBrowser.delegate = self;
    
    
	[netServiceBrowser searchForServicesOfType:serviceName inDomain:@""];
    
}



- (void) netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"not resolved");
}

- (void) initClient:(NSNetService *)pService
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSInputStream *input;
    NSOutputStream *output;
    

    BonjourClient *client = [[BonjourClient alloc] init];
    client.bonjourBrowser = self;
    
    @synchronized(clients)
    {
        [clients addObject:client];
    }
    

    [pService getInputStream:&input outputStream:&output];
    
    NSArray *components = [[pService description] componentsSeparatedByString:@"."];
    NSString *hostName = [components lastObject];
    
    client.hostName = hostName;
    client.inputStream = input;
    client.outputStream = output;
    client.netService = pService;
    [client openStreams];
    
    [input release];
    [output release];

    
    //**********************************************************************    
    /* Check the version */
    BonjourMessage *parameterMessage = [[BonjourMessage alloc] init];
    parameterMessage.messageType = kMessageTypeGetParameters;
    parameterMessage.userData = [[[NSMutableDictionary alloc] init] autorelease];
    
    [client sendBonjourMessage:parameterMessage];
    
    NSLog(@"Configuration checking....");
    [parameterMessage release];
    
    //**********************************************************************    
    
    
    // Send device id
    NSString *deviceIdentifier = [appDelegate getDeviceUniqueIdentifier];
    
    
    BonjourMessage *message = [[BonjourMessage alloc] init];
    message.messageType = kMessageTypeDeviceInfo;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:deviceIdentifier forKey:@"device_id"];
    
    if(appDelegate.guestEnterNumber > 0)
    {
        [dict setValue:[NSNumber numberWithInt:appDelegate.guestEnterNumber] forKey:@"guest_number"];
    }
    
    [client sendDictionary:dict];
    message.userData = dict;
    [dict release];
    
    [client  sendBonjourMessage:message];
    [message release];
    [client release];
}


- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser
{
    NSLog(@"[BONJOUR] tea browsing stoped!");
}

- (void)netServiceDidResolveAddress:(NSNetService *)pService 
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *components = [[pService description] componentsSeparatedByString:@"."];
    NSString *hostName = [components lastObject];

   
   /* if(appDelegate.state == kAppStateLogon) 
    {
        if([hostName isEqualToString:appDelegate.connectedHost])
        {
            
            // Remove clients already connected...
            
            
            @synchronized(clients)
            {
                NSMutableArray *clientsToRemove = [[NSMutableArray alloc] init];
                for(BonjourClient *tClient in clients)
                {
                    if ([tClient.hostName isEqualToString:hostName]) 
                    {
                        [clientsToRemove addObject:tClient];
                    }
                }
                
                for(BonjourClient *tClient in clientsToRemove)
                {
                    [clients removeObject:tClient];
                }
                
                [clientsToRemove release];
            }
            
            
            
            
            [self initClient:pService];
        }
        else
        {
            NSLog(@"[BONJOUR] tea service resolved on %@ but REJECTED!!!", hostName);
        }
    }
    else
    {
        NSLog(@"[BONJOUR] tea service resolved on %@", hostName);
        
        
        // Remove clients already connected...
        NSMutableArray *clientsToRemove = [[NSMutableArray alloc] init];
       
        @synchronized(clients)
        {
            for(BonjourClient *tClient in clients)
            {
                if ([tClient.hostName isEqualToString:hostName]) 
                {
                    [clientsToRemove addObject:tClient];
                }
            }
            
            for(BonjourClient *tClient in clientsToRemove)
            {
                [clients removeObject:tClient];
            }
            
            [clientsToRemove release];
        }
        
        
        
        [self initClient:pService];
    }*/
    
    [self initClient:pService];
}

- (void) stopBrowse
{
    
    
    @synchronized([self bonjourServers])
    {
        [[self bonjourServers] removeAllObjects];
    }
    
    [self.netServiceBrowser stop];
    [self.services removeAllObjects];
    [clients removeAllObjects];
    
    
    NSLog(@"Bonjour service stoped...");
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing 
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *components = [[netService description] componentsSeparatedByString:@"."];
    NSString *hostName = [components lastObject];
    
    if([appDelegate.connectedHost isEqualToString:hostName])
    {
        appDelegate.session.sessionGuid = nil;
        appDelegate.session.sessionName = nil;
        appDelegate.session.sessionLectureName = nil;
        appDelegate.session.sessionLectureGuid  = nil;
        appDelegate.session.sessionTeacherName = nil;
        
        appDelegate.state = kAppStateIdle;
        
        [appDelegate.currentQuizWindow finishQuiz];
    }
    
    @synchronized(clients)
    {
        NSMutableArray *clientsToRemove = [[NSMutableArray alloc] init];
        for(BonjourClient *tClient in clients)
        {
            if ([tClient.hostName isEqualToString:hostName]) 
            {
                [clientsToRemove addObject:tClient];
                NSLog(@"[BONJOUR] tea service removed by host %@", tClient.hostName);
            }
        }
        
        for(BonjourClient *tClient in clientsToRemove)
        {
            [clients removeObject:tClient];
        }
        
        [services removeObject:netService];
        
        [clientsToRemove release];
    }
    
    
}



- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing 
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *components = [[netService description] componentsSeparatedByString:@"."];
    NSString *hostName = [components lastObject];
    
    NSLog(@"Service found on %@", hostName);
  
    if(appDelegate.state == kAppStateLogon) 
    {
        if([hostName isEqualToString:appDelegate.connectedHost])
        {
            NSLog(@"[BONJOUR] tea service found on %@", hostName);
            
            [netService setDelegate:self];
            [netService resolveWithTimeout:0];
            
            [services addObject:netService];
        }
        else
        {
            NSLog(@"[BONJOUR] tea service found on %@ but REJECTED!!!", hostName);
        }
    }
    else
    {
        NSLog(@"[BONJOUR] tea service found on %@", hostName);
        
        [netService setDelegate:self];
        [netService resolveWithTimeout:0];
        
        [services addObject:netService];
    } 
}

- (void) handleTest:(NSStream *)stream
{
    uint8_t buf[1024];
    long len = 0;
    len = [(NSInputStream *)stream read:buf maxLength:1024];
    NSLog(@"read data of size %d", (int) len);
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    
    
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
            
            [NSThread detachNewThreadSelector:@selector(handleTest:) toTarget:self withObject:stream];
            /*uint8_t buf[1024];
             long len = 0;
             //len = [(NSInputStream *)stream read:buf maxLength:1024];
             */
            
            break;
		}
		case NSStreamEventErrorOccurred:
		{
            
			NSLog(@"[BONJOUR] Event error %d", (int) eventCode);
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate * )[[UIApplication sharedApplication] delegate];
            
            [appDelegate restartBonjourBrowser];
            
            break;
		}
			
		case NSStreamEventEndEncountered:
		{
            NSLog(@"[BONJOUR] Event end %d", (int) eventCode);
            
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate * )[[UIApplication sharedApplication] delegate];
            
            [appDelegate restartBonjourBrowser];
            
			break;
		}
	}
}

- (void) sendBonjourMessage:(BonjourMessage*) aMessage toClient:(BonjourClient*) aClient
{
    [aClient sendBonjourMessage:aMessage];
}


- (void) sendBonjourMessageToAllClients:(BonjourMessage*) aMessage 
{
    @synchronized(clients)
    {
        for(BonjourClient *client in clients)
        {
            [self sendBonjourMessage:aMessage toClient:client];
        }
    }
    
}

@end
