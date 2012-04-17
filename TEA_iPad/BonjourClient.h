//
//  BonjourClient.h
//  tea
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>




@class BonjourServer, BonjouClientDataHandler, BonjourMessage, BonjourBrowser;
@interface BonjourClient : NSObject <NSStreamDelegate>

{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *deviceid;
    NSString *type;
    NSMutableData *data;
    NSNetService *netService;
    NSString *hostName;
    BonjourServer *bonjourServer;
    BonjourBrowser *bonjourBrowser;
    BonjouClientDataHandler *dataHandler;
}

- (void) openStreams;
- (void) sendString:(NSString *)dataString groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType;
- (void) sendInt:(int)dataInt groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType;
- (void) sendData:(NSData *)dataValue groupCode:(uint8_t)groupCode groupCodeType:(uint8_t)groupCodetype dataType:(uint8_t)dataType;
- (void) sendDictionary:(NSDictionary *)dict;

- (BOOL) sendBonjourMessage:(BonjourMessage*) aMessage;

@property (nonatomic, retain) NSString *hostName;
@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) NSString *deviceid;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) BonjourServer *bonjourServer;
@property (nonatomic, retain) BonjourBrowser *bonjourBrowser;
@property (nonatomic, retain) BonjouClientDataHandler *dataHandler;

@end
