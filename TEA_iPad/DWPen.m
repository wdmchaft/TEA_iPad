//
//  DWPen.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWPen.h"


@implementation DWPen

- (id) init
{
    self = [super init];
    
    if(self)
    {
        self.drawingItem = [[DWDrawingItemPen alloc] init];
    }
    
    return self;
}

@end
