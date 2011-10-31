
//
//  DWDrawingItemRectangle.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingItemRectangle.h"


@implementation DWDrawingItemRectangle


- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


-(void)drawIntoContext:(CGContextRef)pContext
{
    if([points count]==2)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGPoint lastPos = [[points objectAtIndex:1 ] CGPointValue];
       
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);

        
        CGContextAddRect(pContext,CGRectMake( startPos.x, startPos.y, lastPos.x - startPos.x , lastPos.y - startPos.y)); 
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
