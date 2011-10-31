//
//  DWType.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWType.h"
#import "DWDrawingItemRectangle.h"

@implementation DWType

- (void) drawIntoContext:(CGContextRef)pContext
{
    // init line drawing item...
    DWDrawingItemRectangle *rectangle = [[[DWDrawingItemRectangle alloc] init] autorelease];
    [rectangle drawIntoContext:pContext];
    
}

@end
