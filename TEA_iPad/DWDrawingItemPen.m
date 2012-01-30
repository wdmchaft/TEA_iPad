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
@synthesize vertices;

- (id)init {
    self = [super init];
    if (self) {
        self.vertices = [[NSMutableArray alloc] initWithCapacity:128];
    }
    return self;
}

- (void)dealloc {

    [vertices release];
    [super dealloc];
}

- (CGPoint) centerOfLine:(CGPoint)from to:(CGPoint)to;
{
    return CGPointMake(to.x - ((to.x - from.x) / 2), to.y - ((to.y - from.y) / 2));
}

- (CGFloat) distanceFrom:(CGPoint)from to:(CGPoint)to;
{
    return sqrtf(powf(from.x - to.x, 2.0) + powf(from.y - to.y, 2.0));
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
        CGContextBeginPath(pContext);
        
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
    
    else if([points count] >2)
    {
        

        CGContextBeginPath(pContext);

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
      
}    
   
-(void) addPoint:(CGPoint)pPoint
{
    if([points count] <=0)
    {
        [points addObject:[NSValue valueWithCGPoint:pPoint]];
    }
    else
    {
        CGPoint lastPoint = [[points objectAtIndex:[points count] - 1 ] CGPointValue];
        CGFloat distance = [self distanceFrom:lastPoint to:pPoint];
        
        if(distance > 4.0)
        {
            [points addObject:[NSValue valueWithCGPoint:pPoint]]; 
        }
    }
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
