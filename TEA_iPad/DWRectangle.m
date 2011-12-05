//
//  DWRectangle.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWRectangle.h"
#import "DWDrawingItemRectangle.h"

@implementation DWRectangle


- (id) init
{
    self = [super init];
    
    if(self)
    {
        self.drawingItem = [[[DWDrawingItemRectangle alloc] init] autorelease];
    }
    
    return self;
}




@end
