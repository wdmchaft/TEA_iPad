//
//  BonjourMessageHandler.h
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BonjourMessage;
@interface BonjourMessageHandler : NSObject {
 
    int handlerMessageType;
}

@property (nonatomic, assign) int handlerMessageType;

-(void) handleMessage:(BonjourMessage *) aMessage;


@end
