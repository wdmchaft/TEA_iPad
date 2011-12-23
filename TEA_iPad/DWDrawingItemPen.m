//
//  DWDrawingItemRectangle.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingItemPen.h"
#import <QuartzCore/QuartzCore.h>


@implementation DWDrawingItemPen


- (id)init {
    self = [super init];
    if (self) {
        vertices = [[NSMutableArray alloc] initWithCapacity:128];
    }
    return self;
}

- (void)dealloc {

    [super dealloc];
}


/*
- (void) drawCatmullRomSplines
{
    
	float x, y;
    
   
    
    CGPoint P0 = [[points objectAtIndex:0] CGPointValue];
	CGPoint P1 = [[points objectAtIndex:1] CGPointValue];
	CGPoint P2 = [[points objectAtIndex:2] CGPointValue];
	CGPoint P3 = [[points objectAtIndex:3] CGPointValue];
    

    float segments = 10.0;
    // NSLog(@"Segment count %f", ceil(segments));
    unsigned int num = 1;
    
	float rez = 1.0f /  segments;
    unsigned int max = segments * num;

	unsigned int count = 0;
    
   
    
  //  [vertices addObject:[NSValue valueWithCGPoint:P3]];
    
//	for (int n = 0; n < num; n++) 
    {
        for (float t = 0.0f; t < 1.0f && count < max; t += rez) 
        {
            
            
            x = 0.5 *(  (2 * P1.x) +
                      (-P0.x + P2.x) * t +
                      (2*P0.x - 5*P1.x + 4*P2.x - P3.x) * t*t +
                      (-P0.x + 3*P1.x- 3*P2.x + P3.x) * t*t*t);
            
            y = 0.5 *(  (2 * P1.y) +
                      (-P0.y + P2.y) * t +
                      (2*P0.y - 5*P1.y + 4*P2.y - P3.y) * t*t +
                      (-P0.y + 3*P1.y- 3*P2.y + P3.y) * t*t*t);
        
            
            [vertices addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            
        }
        
        //[vertices addObject:[NSValue valueWithCGPoint:P2]];
    }
   
}
*/
- (CGPoint) centerOfLine:(CGPoint)from to:(CGPoint)to;
{
    return CGPointMake(to.x - ((to.x - from.x) / 2), to.y - ((to.y - from.y) / 2));
}




-(void)drawIntoContext:(CGContextRef)pContext
{
   
    if([points count] == 1)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGContextSetRGBFillColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextFillEllipseInRect(pContext, CGRectMake(startPos.x - lineWidth.lineWidth / 2, startPos.y - lineWidth.lineWidth / 2, lineWidth.lineWidth , lineWidth.lineWidth ));
    }
    else if([points count] == 2)
    {
        CGPoint from = [(NSValue*) [points objectAtIndex:0] CGPointValue];
        CGPoint to = [(NSValue*) [points objectAtIndex:1] CGPointValue];
        CGContextMoveToPoint(pContext, from.x, from.y);
        
        CGContextAddLineToPoint(pContext, to.x, to.y);
  
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextSetLineCap(pContext, kCGLineCapRound);
        CGContextSetLineJoin(pContext, kCGLineJoinRound);
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        CGContextStrokePath(pContext);
    }
    else if([points count] > 2)
    {
        CGPoint from = [(NSValue*) [points objectAtIndex:0] CGPointValue];
        CGPoint to = [(NSValue*) [points objectAtIndex:1] CGPointValue];
        CGPoint center = [self centerOfLine:from to:to];
        CGContextMoveToPoint(pContext, from.x, from.y);
        
        CGContextAddLineToPoint(pContext, center.x, center.y);
        
        
        for (int i=1; i < [points count] - 1; i++) 
        {
            from = [(NSValue*) [points objectAtIndex:i] CGPointValue];
            to = [(NSValue*) [points objectAtIndex:i + 1] CGPointValue];
            center = [self centerOfLine:from to:to];
            
            // CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp1.x, cp1.y, toPoint.x, toPoint.y);
            CGContextAddQuadCurveToPoint(pContext, from.x, from.y, center.x, center.y);
            
        }
        
        
        CGPoint last = [(NSValue*) [points objectAtIndex:[points count] -1 ] CGPointValue];
        CGContextAddLineToPoint(pContext, last.x, last.y);
        //CGContextDrawPath(pContext, kCGPathStroke);
        
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextSetLineCap(pContext, kCGLineCapRound);
        CGContextSetLineJoin(pContext, kCGLineJoinRound);
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        CGContextStrokePath(pContext);
        
    }
    
    
    /*
    if([points count] == 1)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGContextSetRGBFillColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextFillEllipseInRect(pContext, CGRectMake(startPos.x - lineWidth.lineWidth / 2, startPos.y - lineWidth.lineWidth / 2, lineWidth.lineWidth , lineWidth.lineWidth ));
    }

    else if([points count] >= 4)
    {
        [self drawCatmullRomSplines];
        CGPoint startPos = [[vertices objectAtIndex:0 ] CGPointValue];
         
        CGContextBeginPath(pContext);
 
        CGContextMoveToPoint(pContext, startPos.x, startPos.y);
        for (int i=1; i<[vertices count]; i+=1) 
        {
            CGPoint lastPos = [[vertices objectAtIndex:i ] CGPointValue];
            CGContextAddLineToPoint(pContext, lastPos.x, lastPos.y);
            //CGContextAddQuadCurveToPoint(pContext, cp.x, cp.y, lastPos.x, lastPos.y);

        }
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextSetLineCap(pContext, kCGLineCapRound);
        CGContextSetLineJoin(pContext, kCGLineJoinRound);
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        CGContextStrokePath(pContext);
        
       
    }*/
      
}    
   
- (CGFloat) distanceFrom:(CGPoint)from to:(CGPoint)to;
{
    return sqrtf(powf(from.x - to.x, 2.0) + powf(from.y - to.y, 2.0));
}


-(void) addPoint:(CGPoint)pPoint
{
   
    CGFloat distance = 0.0;
    if([points count] > 0)
    {
        CGPoint lastPoint = [[points objectAtIndex:[points count] - 1 ] CGPointValue];
        distance = [self distanceFrom:lastPoint to:pPoint];
        
        if(distance > 4.0)
        {
            [points addObject:[NSValue valueWithCGPoint:pPoint]];
            
        }

    }
    else
    {
        [points addObject:[NSValue valueWithCGPoint:pPoint]];
    }
        
    
    
    /*
    
    [points addObject:[NSValue valueWithCGPoint:pPoint]];

    
    if([points count] >= 5)
    {
        [points removeObjectAtIndex:0];
        
    }*/
}

- (void) resetDrawingItem
{
    /*
    for (int i=0; i < [points count]; i++) 
    {
        CGPoint n = [[points objectAtIndex:i] CGPointValue];
        NSLog(@"p %f, %f", n.x, n.y);
    }
    
    for (int i=0; i < [cpoints count]; i++) 
    {
        CGPoint n = [[cpoints objectAtIndex:i] CGPointValue];
        NSLog(@"cp %f, %f", n.x, n.y);
    }
    */
    [points removeAllObjects];
    [vertices removeAllObjects];

}

@end
