//
//  DWTool.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWTool.h"


@implementation DWTool

@synthesize drawingItem;

-(void)drawIntoContext:(CGContextRef)pContext
{
    
}

-(void) didDraw
{
}

- (void) resetTool
{
    [drawingItem resetDrawingItem];
}

- (void)dealloc {
    [drawingItem release];
    [super dealloc];
}

@end
