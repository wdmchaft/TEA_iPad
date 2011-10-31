//
//  DWDrawingView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTool.h"
#import "DWScale.h"
#import "DWPen.h"
#import "DWDrawingItem.h"
#import "DWDrawingItemRectangle.h"
#import "DWDrawingItemPen.h"
#import "DWRectangle.h"
#import "DWLine.h"
#import "DWEraser.h"
#import "DWOval.h"

@interface DWDrawingView : UIView 
{
    DWTool *currentTool;
    UIImage *contextImage;
    DWScale *zoomLevel;
    CGPoint firstTouchLocation;
    CGContextRef drawingContext;
    
    DWPen *penTool;
    DWRectangle *rectangleTool;
    DWLine *lineTool;
    DWEraser *eraserTool;
    DWOval *ovalTool;
    
    CGRect currentImageFrame;
}

// TOOLS
@property (nonatomic, retain) DWPen *penTool;
@property (nonatomic, retain) DWRectangle *rectangleTool;
@property (nonatomic, retain) DWLine *lineTool;
@property (nonatomic, retain) DWEraser *eraserTool;
@property (nonatomic, retain) DWOval *ovalTool;
@property (nonatomic, assign) UIImage *contextImage;
@property (retain) NSMutableArray *drawingItemList;
@property (assign) DWTool *currentTool;


- (UIImage*) screenImage;

@end
