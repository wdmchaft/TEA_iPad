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
    }
    return self;
}

- (void)dealloc {

    [super dealloc];
}

CGPoint tangent(CGPoint p1, CGPoint p2) {
	return CGPointMake((p1.x - p2.x) / 4.0, (p1.y - p2.y) / 4.0f);
}

- (void) drawCatmullRomSplines
{
	float px, py;
	float tt, _1t, _2t;
	float h00, h10, h01, h11;
	CGPoint m0;
	CGPoint m1;
	CGPoint m2;
	CGPoint m3;
    

    unsigned int segments = 64;
    unsigned int num = [points count];
    
	float rez = 1.0f / segments;
    if(vertices)
    {
        [vertices release];
        vertices = nil;
    }
    
    if(!vertices)
    {
        vertices = [[NSMutableArray alloc] initWithCapacity:(segments * num)];
    }
    
//	CGPoint vertices[segments * num];
	unsigned int count = 0;
    
	for (int n = 0; n < num; n++) {
        
		for (float t = 0.0f; t < 1.0f; t += rez) {
			tt = t * t;
			_1t = 1 - t;
			_2t = 2 * t;
			h00 =  (1 + _2t) * (_1t) * (_1t);
			h10 =  t  * (_1t) * (_1t);
			h01 =  tt * (3 - _2t);
			h11 =  tt * (t - 1);
            
			if (!n) {
                
				m0 = tangent([((NSValue *) [points objectAtIndex:n+1]) CGPointValue], [((NSValue *) [points objectAtIndex:n]) CGPointValue]);
				m1 = tangent([((NSValue *) [points objectAtIndex:n+2]) CGPointValue], [((NSValue *) [points objectAtIndex:n]) CGPointValue]);
				px = h00 * [((NSValue *) [points objectAtIndex:n]) CGPointValue].x + h10 * m0.x + h01 * [((NSValue *) [points objectAtIndex:n+1]) CGPointValue].x + h11 * m1.x;
				py = h00 * [((NSValue *) [points objectAtIndex:n]) CGPointValue].y + h10 * m0.y + h01 * [((NSValue *) [points objectAtIndex:n+1]) CGPointValue].y + h11 * m1.y;
                
                [vertices insertObject:[NSValue valueWithCGPoint:CGPointMake(px, py)] atIndex:count++];
			//	vertices[count++] = CGPointMake(px, py);
			}
			else if (n < num-2)
			{
				m1 = tangent([((NSValue *) [points objectAtIndex:n+1]) CGPointValue], [((NSValue *) [points objectAtIndex:n-1]) CGPointValue]);
				m2 = tangent([((NSValue *) [points objectAtIndex:n+2]) CGPointValue], [((NSValue *) [points objectAtIndex:n]) CGPointValue]);
				px = h00 * [((NSValue *) [points objectAtIndex:n]) CGPointValue].x + h10 * m1.x + h01 * [((NSValue *) [points objectAtIndex:n+1]) CGPointValue].x + h11 * m2.x;
				py = h00 * [((NSValue *) [points objectAtIndex:n]) CGPointValue].y + h10 * m1.y + h01 * [((NSValue *) [points objectAtIndex:n+1]) CGPointValue].y + h11 * m2.y;
              
                [vertices insertObject:[NSValue valueWithCGPoint:CGPointMake(px, py)] atIndex:count++];
			//	vertices[count++] = CGPointMake(px, py);
			}
			else if (n == num-1)
			{
				m2 = tangent([((NSValue *) [points objectAtIndex:n]) CGPointValue], [((NSValue *) [points objectAtIndex:n-2]) CGPointValue]);
				m3 = tangent([((NSValue *) [points objectAtIndex:n]) CGPointValue], [((NSValue *) [points objectAtIndex:n-1]) CGPointValue]);
				px = h00 * [((NSValue *) [points objectAtIndex:n-1]) CGPointValue].x + h10 * m2.x + h01 * [((NSValue *) [points objectAtIndex:n]) CGPointValue].x + h11 * m3.x;
				py = h00 * [((NSValue *) [points objectAtIndex:n-1]) CGPointValue].y + h10 * m2.y + h01 * [((NSValue *) [points objectAtIndex:n]) CGPointValue].y + h11 * m3.y;
                
                [vertices insertObject:[NSValue valueWithCGPoint:CGPointMake(px, py)] atIndex:count++];
			//	vertices[count++] = CGPointMake(px, py);
			}  
            
		}
        
	}
   
}


-(void)drawIntoContext:(CGContextRef)pContext
{
    if([points count] == 1)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGContextSetRGBFillColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextFillEllipseInRect(pContext, CGRectMake(startPos.x, startPos.y, lineWidth.lineWidth, lineWidth.lineWidth));
    }
    else
    if([points count] >= 4)
    {
        
       // [self drawCatmullRomSplines];
        
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        
        
        CGContextBeginPath(pContext);
        
        CGContextMoveToPoint(pContext, startPos.x, startPos.y);
        for (int i=3; i<[points count]; i+=3) {
            CGPoint cp1 = [[points objectAtIndex:i-2 ] CGPointValue];
            CGPoint cp2 = [[points objectAtIndex:i-1 ] CGPointValue];
            CGPoint lastPos = [[points objectAtIndex:i ] CGPointValue];
            
           // CGContextAddQuadCurveToPoint(pContext, cp1.x * cp1.x, cp1.y * cp1.y, lastPos.x, lastPos.y);
            CGContextAddCurveToPoint(pContext, cp1.x, cp1.y, cp2.x, cp2.y, lastPos.x, lastPos.y);
            
           // CGContextAddLineToPoint(pContext, lastPos.x, lastPos.y);
        }
        
      /*  CGContextMoveToPoint(pContext, startPos.x, startPos.y);
        for (int i=1; i<[points count]; i++) {
            CGPoint lastPos = [[points objectAtIndex:i ] CGPointValue];
            CGContextAddLineToPoint(pContext, lastPos.x, lastPos.y);
        }
        */
        
       /* CGPoint startPos = [[vertices objectAtIndex:0 ] CGPointValue];
        
        CGContextBeginPath(pContext);
        CGContextMoveToPoint(pContext, startPos.x, startPos.y);

        
        for (int i=1; i<[vertices count]; i++) 
        {
            CGPoint lastPos = [[vertices objectAtIndex:i ] CGPointValue];
            
            CGContextAddLineToPoint(pContext, lastPos.x, lastPos.y);
        
        }*/
        
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        CGContextSetLineCap(pContext, kCGLineCapRound);
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        CGContextStrokePath(pContext);
        
        //[points removeObjectAtIndex:0];
    }
    
}    
   
-(void) addPoint:(CGPoint)pPoint
{
    [points addObject:[NSValue valueWithCGPoint:pPoint]];
}

- (void) resetDrawingItem
{
    [points removeAllObjects];
    [vertices removeAllObjects];
    [vertices release];
    vertices = nil;
}

@end
