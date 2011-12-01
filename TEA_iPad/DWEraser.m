//
//  DWEraser.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWEraser.h"


@implementation DWEraser

- (id) init
{
    self = [super init];
    
    if(self)
    {
        self.drawingItem = [[[DWDrawingItemEraser alloc] init] autorelease];
    }
    
    return self;
}

@end
