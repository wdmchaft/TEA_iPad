//
//  BonjourMessageManager.h
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BonjourMessageHandlerManager : NSObject {
    
    NSMutableArray *bonjourMessageHandlers;
}

+ (BonjourMessageHandlerManager*) sharedInstance;

@property (assign) NSMutableArray *bonjourMessageHandlers;

@end
