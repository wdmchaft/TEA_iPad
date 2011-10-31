//
//  BonjourMessage.h
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>




@class BonjourClient;
@interface BonjourMessage : NSObject 
{
    
    NSString *guid;
    int messageType;
    NSDictionary *userData;
    BonjourClient *client;
}

+ (NSData*) dataWithMessage:(BonjourMessage*) aMessage;

@property (nonatomic, retain) NSString *guid;
@property (nonatomic, assign) int messageType;
@property (nonatomic, retain) NSDictionary *userData;
@property (nonatomic, retain) BonjourClient *client;

@end
