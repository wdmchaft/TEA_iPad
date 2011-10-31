//
//  DWDrawingItemRectangle.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingItemLine.h"


@implementation DWDrawingItemLine

int diffX,diffY;


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


-(void)drawIntoContext:(CGContextRef)pContext
{
    if([points count]==2)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGPoint lastPos = [[points objectAtIndex:1 ] CGPointValue];
        CGContextMoveToPoint(pContext, startPos.x, startPos.y);
        
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        
        CGContextAddLineToPoint(pContext, lastPos.x, lastPos.y);
        //CGContextAddRect(pContext,CGRectMake( startPos.x, startPos.y, lastPos.x - startPos.x , lastPos.y - startPos.y)); 
        CGContextStrokePath(pContext);
    }
  
}

- (void) resetDrawingItem
{
    [points removeAllObjects];
}

-(void) addPoint:(CGPoint)pPoint
{
    [points addObject:[NSValue valueWithCGPoint:pPoint]];
    
    if([points count] >= 2)
    {
        if([points count] == 3)
        {
            [points removeObjectAtIndex:1];
        }
    }
    
}


@end
