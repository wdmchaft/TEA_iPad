//
//  DWLine.m
//  TEA_iPad
//
//  Created by GURKAN CALIK on 7/30/11.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWLine.h"


@implementation DWLine


- (id) init
{
    self = [super init];
    
    if(self)
    {
        self.drawingItem = [[DWDrawingItemLine alloc] init];
    }
    
    return self;
}

@end
