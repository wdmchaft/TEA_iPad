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


-(void)drawIntoContext:(CGContextRef)pContext
{
    /*
    if([points count] >= 3)
    {
        [self drawCatmullRomSplines];
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGContextBeginPath(pContext);
        CGContextMoveToPoint(pContext, startPos.x, startPos.y);
        
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextSetLineCap(pContext, kCGLineCapRound);
        CGContextSetLineJoin(pContext, kCGLineJoinRound);
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
              
        for (int i=2; i < [points count] ; i+= 2) 
        {
            NSLog(@"i is %d", i);
            
            
            CGPoint nextPoint = [[points objectAtIndex:i ] CGPointValue];
            
            CGPoint cp = [[cpoints objectAtIndex:(i / 2) - 1 ] CGPointValue];
            
            //CGContextAddLineToPoint(pContext, nextPoint.x, nextPoint.y);
            CGContextAddQuadCurveToPoint(pContext, cp.x, cp.y, nextPoint.x, nextPoint.y);
        }
        CGContextStrokePath(pContext);*/
      /* CGContextStrokePath(pContext);
        
        for (int i=2; i < [points count] ; i+= 2) 
        {
            
            CGPoint cp = [[points objectAtIndex:i ] CGPointValue];
                        
            CGContextSetRGBFillColor(pContext, 0, 0, 1, 1);
            CGContextFillEllipseInRect(pContext, CGRectMake(cp.x - 1 , cp.y - 1, 2 , 2));
        }
        
        
        for (int i=2; i < [points count] ; i+= 2) 
        {
            
            CGPoint cp = [[points objectAtIndex:i - 1 ] CGPointValue];
            //   NSLog(@"cp %f, %f", cp.x, cp.y);
            CGContextSetRGBFillColor(pContext, 0, 1, 0, 1);
            CGContextFillEllipseInRect(pContext, CGRectMake(cp.x - 1 , cp.y - 1, 2 , 2));
            
        }
        
        for (int i=0; i < [cpoints count]; i+= 1) 
        {
            
            CGPoint cp = [[cpoints objectAtIndex:i ] CGPointValue];
         //   NSLog(@"cp %f, %f", cp.x, cp.y);
            CGContextSetRGBFillColor(pContext, 1, 0, 0, 1);
            CGContextFillEllipseInRect(pContext, CGRectMake(cp.x - 1 , cp.y - 1, 2 , 2));
           
        }
        */
   // }
    
    
    
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
        
       
    }
      
}    
   
-(void) addPoint:(CGPoint)pPoint
{
    [points addObject:[NSValue valueWithCGPoint:pPoint]];
    
    /*[points addObject:[NSValue valueWithCGPoint:CGPointMake(1, 1)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(6, 2)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(5, 4)]];
    */
    //NSLog(@"point count %d", [points count]);
    /*if([points count] == 1)
    {
        [points addObject:[NSValue valueWithCGPoint:pPoint]];
    }*/
    
/*
    if([points count] >= 3)
    {
        if([points count] % 2 == 1) // generate control point for every three points
        {
            CGPoint n = [[points objectAtIndex:([points count] - 3)] CGPointValue];
            CGPoint n_1 = [[points objectAtIndex:([points count] - 2)] CGPointValue];
            CGPoint n_2 = [[points objectAtIndex:([points count] - 1)] CGPointValue];
            
            float m;
            if((n_2.x - n.x) == 0)
            {
                m = (n_2.y - n.y);
            }
            else
            {
                m = (n_2.y - n.y) / (n_2.x - n.x);
            }

            float b = n_2.y - (m * n_2.x);
            
            float x0 = ((m * n_1.y) + n_1.x - (m * b)) / ((m * m) + 1);
            float y0 = (m * x0) + b;
  
            float roundC = 2.2;
            CGPoint dist = CGPointMake((n_1.x - x0) * roundC, (n_1.y - y0) * roundC);
            CGPoint cp = CGPointMake(n_1.x + dist.x, n_1.y + dist.y);
            [cpoints addObject:[NSValue valueWithCGPoint:cp]];
            


        }*/
    if([points count] >= 5)
    {
        [points removeObjectAtIndex:0];
        
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
