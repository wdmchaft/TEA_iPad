//
//  DWTool.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDrawingItem.h"

@interface DWTool : NSObject {
    DWDrawingItem *drawingItem;
}

@property (nonatomic,retain) DWDrawingItem *drawingItem;

- (void) drawIntoContext:(CGContextRef) pContext;
- (void) didDraw;
- (void) resetTool;

@end
