//
//  DWDrawingStackItem.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWColor.h"
#import "DWLineWidth.h"
#import "DWLineStyle.h"
#import "DWTransparency.h"
#import "DWFont.h"
#import "DWScale.h"
#import "DWLocation.h"
#import "DWRotate.h"
#import "DWFlip.h"

@class DWDrawingView;
@interface DWDrawingItem : NSObject 
{
    NSMutableArray *points;
    
    DWColor *lineColor;
    DWLineWidth *lineWidth;
    DWLineStyle *lineStyle;
    DWColor *fillColor;
    DWFont *font;
    DWTransparency *transparency;
    DWScale *scale;
    DWRotate *rotate;
    DWFlip *flip;

    void *bitmapData;
}

@property (retain) NSMutableArray *points;
@property (retain) DWColor *lineColor;
@property (retain) DWLineWidth *lineWidth;
@property (retain) DWLineStyle *lineStyle;
@property (retain) DWColor *fillColor;
@property (retain) DWFont *font;
@property (retain) DWTransparency *transparency;
@property (retain) DWScale *scale;
@property (retain) DWRotate *rotate;
@property (retain) DWFlip *flip;


- (void) drawIntoContext:(CGContextRef) pContext;
- (void) didDraw;
- (void) addPoint:(CGPoint) pPoint;
- (UIImage *)drawIntoImage:(UIImage *)pImage withRect:(CGRect)pRect;
- (NSString*) getXML;
- (void) resetDrawingItem;


@end
