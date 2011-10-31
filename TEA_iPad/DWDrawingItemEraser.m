//
//  DWDrawingItemRectangle.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingItemEraser.h"


@implementation DWDrawingItemEraser


- (id)init 
{
    self = [super init];
    if (self) 
    {
        lineWidth.lineWidth = 30;
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}


-(void)drawIntoContext:(CGContextRef)pContext
{
    
    if([points count]>1)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGContextSetBlendMode(pContext, kCGBlendModeClear);
        CGContextBeginPath(pContext);
        CGContextMoveToPoint(pContext, startPos.x, startPos.y);
        
        for (int i=1; i<[points count]; i++) 
        {
            CGPoint lastPos = [[points objectAtIndex:i ] CGPointValue];
            CGContextAddLineToPoint(pContext, lastPos.x, lastPos.y);
        }
        
        // CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        CGContextStrokePath(pContext);
        CGContextSetBlendMode(pContext, kCGBlendModeNormal);
    }
    
}    

-(void) addPoint:(CGPoint)pPoint
{
    [points addObject:[NSValue valueWithCGPoint:pPoint]];
   
}



- (void) resetDrawingItem
{
    [points removeAllObjects];
}

@end
