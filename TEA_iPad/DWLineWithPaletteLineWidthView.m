//
//  DWLineWithPaletteLineWidthView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWLineWithPaletteLineWidthView.h"


@implementation DWLineWithPaletteLineWidthView
@synthesize lineWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) setLineWidth:(CGFloat)aLineWidth
{
    lineWidth = aLineWidth;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    
    CGFloat x = (rect.size.width - lineWidth) / 2.0;
    CGFloat y = (rect.size.height - lineWidth) / 2.0;
    
    CGRect circle = CGRectMake(x, y, lineWidth, lineWidth);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextAddEllipseInRect(context, circle); 
    CGContextFillPath(context);
    
}


- (void)dealloc
{
    [super dealloc];
}

@end
