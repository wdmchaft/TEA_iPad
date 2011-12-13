//
//  DWClientDataHandler.m
//  BonjourServer
//
//  Created by Oguz Demir on 28/6/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "TEA_iPadAppDelegate.h"

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
 
    while ([_data length] > 44) // There is enough data
    {
        NSString *messageGuid = [[[NSString alloc] initWithData:[_data subdataWithRange:NSMakeRange(0, 36 )] encoding:NSASCIIStringEncoding ] autorelease];
        int typeBits = 0; [_data getBytes:&typeBits range:NSMakeRange(36, 4)];
        int lengthBits = 0; [_data getBytes:&lengthBits range:NSMakeRange(40, 4)];
        
        if([_data length] < lengthBits + 44 )
        {
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:[NSNumber numberWithInt:lengthBits + 44] forKey:@"totalBytes"];
            [dictionary setValue:[NSNumber numberWithInt:[_data length]] forKey:@"bytes"];
    
            [appDelegate.viewController receivedContentBytes:dictionary];
            [dictionary release];
            
            NSLog(@"still collecting data, total collected : %u, data size: %d", [_data length] , lengthBits + 44);
            break;
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
        
        
        BonjourMessageHandler *handler = [self findMessageHandlerForMessage:message];
        if(handler)
        {
            [NSThread detachNewThreadSelector:@selector(handleMessage:) toTarget:handler withObject:message];
        }
        
        [message release];
        
        /*uint8 groupBits = 0; [_data getBytes:&groupBits range:NSMakeRange(0, 1)];
        uint8 groupTypeBits = 0; [_data getBytes:&groupTypeBits range:NSMakeRange(1, 1)];
        uint8 dataTypeBits = 0; [_data getBytes:&dataTypeBits range:NSMakeRange(2, 1)];
        uint32 lengthBits = 0; [_data getBytes:&lengthBits range:NSMakeRange(3, 4)];
        
        NSLog(@"group %d", groupBits);
        NSLog(@"group type %d", groupTypeBits);
        NSLog(@"data type %d", dataTypeBits);
        NSLog(@"length %d", lengthBits);
        
  
        // HANDLE QUIZ
        else if(groupBits == kDataGroupQuiz)
        {
            if(groupTypeBits == kDataGroupQuizAnswer)
            {
                int answer = 0;
                [_data getBytes:&answer range:NSMakeRange(7, lengthBits)];
                
                QuizResult *quizResultWindow = (QuizResult*) [WindowFactory getOpenedWindowByClass:[QuizResult class]];
                if(quizResultWindow)
                {
                    [quizResultWindow receivedAnswer:answer];
                }
            }
            else if(groupTypeBits == kDataGroupQuizAnswerTime)
            {
                int solutionTime = 0;
                [_data getBytes:&solutionTime range:NSMakeRange(7, lengthBits)];
                
                QuizResult *quizResultWindow = (QuizResult*) [WindowFactory getOpenedWindowByClass:[QuizResult class]];
                if(quizResultWindow)
                {
                    [quizResultWindow receivedSolutionTime:solutionTime];
                }
            }
        }
        
        // HANDLE NOTIFICATIONS
        else if(groupBits == kDataGroupNotification)
        {
            if(groupTypeBits == kDataGroupNotificationStart)
            {
                if(notificationAttributes)
                {
                    [notificationAttributes release];
                    notificationAttributes = nil;
                }
                
                notificationAttributes = [[NSMutableDictionary alloc] init];
            }
            else if(groupTypeBits == kDataGroupNotificationCode)
            {
                int notificationCode = 0;
                [_data getBytes:&notificationCode range:NSMakeRange(7, lengthBits)];
                [notificationAttributes setValue:[NSNumber numberWithInt:notificationCode] forKey:@"notificationCode"];
                [notificationAttributes setValue:client.deviceid forKey:@"deviceId"];
            }
            else if(groupTypeBits == kDataGroupNotificationEnd)
            {
                [[NotificationManager defaultNotificationManager] displayNotifificationWithDictionary:notificationAttributes];
            }
        }
        else if(groupBits == kDataGroupContent)
        {
            if(groupTypeBits == kDataGroupContentType)
            {
                long longData = 0; 
                [_data getBytes:&longData range:NSMakeRange(7, lengthBits)];

                contentType = longData;
                
                if(contentType == kContentTypeImage)
                {

                }
            }

         
            else if(groupTypeBits == kDataGroupContentSize)
            {
                long longData = 0; 
                [_data getBytes:&longData range:NSMakeRange(7, lengthBits)];

            }
            else if(groupTypeBits == kDataGroupContentStarted)
            {

            }
            else if(groupTypeBits == kDataGroupContentEnded)
            {

            }
            
            else if(groupTypeBits == kDataGroupContentData)
            {
               
                if([_data length] < lengthBits + 7)
                {
                    NSLog(@"still collecting data %lu, %d", [_data length] , lengthBits + 7);
                    break;
                }
                
                if(contentType == kContentTypeImage)
                {
                    @synchronized(_data)
                    {

                        NSData *imageData = [_data subdataWithRange:NSMakeRange(7, lengthBits)];
                        
                        NSImage *imageTmp = [[NSImage alloc] initWithData:imageData];
                        
                        ImageView *imageView = (ImageView*)[WindowFactory getWindowControllerByClass:[ImageView class] fromCache:YES];
                        imageView.initialImage = imageTmp;
                        [imageView showWindow:nil];
                        [imageTmp release];
                                                
                    }
                }
            }
        }*/
        //[_data replaceBytesInRange:NSMakeRange(0, 7 + lengthBits) withBytes:NULL length:0];
    }
    
}

- (void)dealloc {
    [bonjourMessageHandlers release];
  //  [client release];
    [_data release];
    [super dealloc];
}

@end
