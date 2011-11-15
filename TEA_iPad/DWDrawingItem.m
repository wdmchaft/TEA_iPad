//
//  DWDrawingStackItem.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingItem.h"


@implementation DWDrawingItem
@synthesize points, lineColor, lineWidth, lineStyle, fillColor, font, transparency, scale, rotate, flip;


- (id)init
{
    self.points = [[NSMutableArray alloc]init];
    self.lineColor = [[DWColor alloc] init];
    self.lineWidth = [[DWLineWidth alloc] init];
 
    return self;
}




CGContextRef createBitmapContext (int pixelsWide,
                                  int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    bitmapData = calloc( 1, bitmapByteCount );
    
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        CGColorSpaceRelease( colorSpace );
        free (bitmapData);
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );
    
    return context;
}


-(UIImage *)drawIntoImage:(UIImage *)pImage withRect:(CGRect)pRect
{
    CGContextRef bitmapContext = createBitmapContext(pRect.size.width, pRect.size.height);
         
    CGContextDrawImage(bitmapContext, pRect, [pImage CGImage]);

    [self drawIntoContext:bitmapContext];
    CGContextStrokePath(bitmapContext);
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(bitmapContext);
    
    if(image)
    {
        return image ;
    }
    
    return nil;
}


- (void) dealloc
{
    [points release];
    [lineColor release];
    [lineWidth release];
    [lineStyle release];
    [fillColor release];
    [font release];
    [transparency release];
    [scale release];
    [rotate release];
    [flip release];

    [super dealloc];
}


- (void) drawIntoContext:(CGContextRef) pContext {}

- (void) didDraw {}

- (void) addPoint:(CGPoint) pPoint {}

- (NSString*) getXML { return nil; }

- (void) resetDrawingItem {}


@end
