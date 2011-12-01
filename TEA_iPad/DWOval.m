//
//  DWOval.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWOval.h"


@implementation DWOval

- (id) init
{
    self = [super init];
    
    if(self)
    {
        self.drawingItem = [[[DWDrawingItemOval alloc] init] autorelease];
    }
    
    return self;
}

@end
