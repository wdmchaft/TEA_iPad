//
//  BonjourClient.m
//  tea
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "BonjourBrowser.h"
#import "TEA_iPadAppDelegate.h"

@implementation BonjourClient

@synthesize deviceid;
@synthesize type;
@synthesize inputStream;
@synthesize outputStream;
@synthesize data;
@synthesize bonjourServer;
@synthesize dataHandler;
@synthesize bonjourBrowser;
@synthesize hostName, netService;

/*- (void) tick
{
    while(true)
    {
        sleep(2);
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        if(bonjourBrowser)
            NSLog(@"bonjour browser is alive :");
        else
            NSLog(@"bonjour browser is morto :");
        
        BonjourMessage *ping = [[[BonjourMessage alloc] init] autorelease];
        ping.messageType = 100;
        [bonjourBrowser sendBonjourMessageToAllClients:ping];
        
        [pool release];
        
    }

   
}
*/

- (id)init
{
    self = [super init];
    if (self) 
    {
        dataHandler = [[BonjouClientDataHandler alloc] init];
        dataHandler.client = self;
        
        
    }
    
    return self;
}

- (void) closeStreams
{
    
 
    
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    inputStream.delegate = nil;
    [inputStream release];
    inputStream = nil;
	
    
    
    outputStream.delegate = nil;
    [outputStream release];
    outputStream = nil;

}

- (void)dealloc
{
    [self closeStreams];
    

    
    [hostName release];
    [deviceid release];
    [dataHandler release];
    [netService release];
    [bonjourBrowser release];
    [bonjourServer release];
    
    [data release];
    [type release];
    
    [super dealloc];
}

- (void) openStreams
{
    inputStream.delegate = self;
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream open];
	outputStream.delegate = self;
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream open];
    
   // [NSThread detachNewThreadSelector:@selector(tick) toTarget:self withObject:nil];
}


- (void) sendString:(NSString *)dataString groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType
{
    [self sendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]  groupCode:groupCode groupCodeType:groupCodetype dataType:dataType];
}

- (void) sendInt:(int)dataInt groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType
{
    [self sendData:[NSData dataWithBytes:&dataInt length:sizeof(int)]  groupCode:groupCode groupCodeType:groupCodetype dataType:dataType];
}

- (void) sendBonjourMessageWithNewThread:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Serialize userData
    NSMutableData *_data = [NSMutableData dataWithData:[BonjourMessage dataWithMessage:aMessage]];  
    
    uint32_t length = (uint32_t) [_data length];
    int totalSentBytes = 0;
    
    
    while (totalSentBytes < length) 
    {
        if (outputStream && [outputStream hasSpaceAvailable])
        {
            int sentBytes = (int) [outputStream write:(uint8_t *)[_data bytes] maxLength:[_data length]];
            
            if(sentBytes < 0)
            {
                NSLog(@"******* Data göndermede problem oluştu!!!!");
                break;
            }
            
            [_data replaceBytesInRange:NSMakeRange(0, sentBytes) withBytes:NULL length:0];
            totalSentBytes += sentBytes;
            NSLog(@" ____ sent bytes %d", sentBytes);
        }
        else
        {

        }
    }
    
    [pool release];
}

- (void) sendBonjourMessage:(BonjourMessage*) aMessage
{
    
    [NSThread detachNewThreadSelector:@selector(sendBonjourMessageWithNewThread:) toTarget:self withObject:aMessage];

}

- (void) sendDictionary:(NSDictionary *)dict
{
    NSData *_data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];    
    NSMutableData *dataValue = [[NSMutableData alloc] init];
    uint32_t length = (uint32_t) [dataValue length];
    [dataValue appendData:[NSData dataWithBytes:(char *) &length length:sizeof(uint32_t)]];
    [dataValue appendData:_data];
    
    int totalSentBytes = 0;
    
    
    while (totalSentBytes < length) 
    {
        if (outputStream && [outputStream hasSpaceAvailable])
        {
            int sentBytes = (int) [outputStream write:(uint8_t *)[dataValue bytes] maxLength:[dataValue length]];
            [dataValue replaceBytesInRange:NSMakeRange(0, sentBytes) withBytes:NULL length:0];
            totalSentBytes += sentBytes;
            NSLog(@" ____ sent bytes %d", totalSentBytes);
        }
    }
    [dataValue release];
}

- (void) sendData:(NSData *)dataValue groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType
{
    int totalSentBytes = 0;
    uint32_t length = (uint32_t) [dataValue length];
    
    NSMutableData *tmpData = [[NSMutableData alloc] init];
    [tmpData appendData:[NSData dataWithBytes:(char *) &groupCode length:1]];
    [tmpData appendData:[NSData dataWithBytes:(char *) &groupCodetype length:1]];
    [tmpData appendData:[NSData dataWithBytes:(char *) &dataType length:1]];
    [tmpData appendData:[NSData dataWithBytes:(char *) &length length:sizeof(uint32_t)]];
    [tmpData appendData:dataValue];
    
    while (totalSentBytes < length) 
    {
        if (outputStream && [outputStream hasSpaceAvailable])
        {
            int sentBytes = (int) [outputStream write:(uint8_t *)[tmpData bytes] maxLength:[tmpData length]];
            [tmpData replaceBytesInRange:NSMakeRange(0, sentBytes) withBytes:NULL length:0];
            totalSentBytes += sentBytes;
            NSLog(@" ____ sent bytes %d", totalSentBytes);
        }
    }
    [tmpData release];
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
            uint8_t buf[20000];
            long len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:20000];
            
            if(len >=0) 
            {
                @try 
                {
                    [dataHandler._data appendBytes:(const void *)buf length:len];
                    [dataHandler handleData];
                }
                @catch (NSException *exception) 
                {
                    NSLog(@"*** !!! Has problem on reading data from stream %@", [(NSInputStream *)stream description]);
                    NSLog(@"*** !!! Length is %d", len);
                }

            }
            else
            {
                 NSLog(@"** !!! Has problem on reading data from stream %@", [(NSInputStream *)stream description]);
            }
            break;
		}
            
		case NSStreamEventErrorOccurred:
		{
            NSLog(@"[BONJOUR] event error %d", (int) eventCode);
			[bonjourBrowser.clients removeObject:self];
            [bonjourServer.clients removeObject:self];
            break;
		}
			
		case NSStreamEventEndEncountered:
		{
            NSLog(@"[BONJOUR] client closed or droped connection");
            
           /* Attendance *attendanceWindow = (Attendance*) [WindowFactory getOpenedWindowByClass:[Attendance class]];
            if(attendanceWindow)
            {
                [attendanceWindow deviceLooseConnectionToService:self.deviceid ];
            }*/
            
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            if([appDelegate.connectedHost isEqualToString:self.hostName])
            {
                appDelegate.session.sessionGuid = nil;
                appDelegate.session.sessionName = nil;
                appDelegate.session.sessionLectureName = nil;
                appDelegate.session.sessionLectureGuid  = nil;
                appDelegate.session.sessionTeacherName = nil;
                
                appDelegate.state = kAppStateIdle;
                
                [appDelegate restartBonjourBrowser] ;
            }
            else
            {
                [bonjourBrowser.clients removeObject:self];
            }
			break;
		}
	}
}

@end
