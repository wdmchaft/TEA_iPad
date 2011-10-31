//
//  DWColor.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWAttribute.h"

@interface DWColor : DWAttribute {
    CGFloat redColorValue;
    CGFloat greenColorValue;
    CGFloat blueColorValue;
    CGFloat alphaColorValue;
}

@property (assign)  CGFloat redColorValue;
@property (assign)  CGFloat greenColorValue;
@property (assign)  CGFloat blueColorValue;
@property (assign)  CGFloat alphaColorValue;

-(void) setColorWithColors:(CGFloat) pRed Green:(CGFloat)pGreen  Blue:(CGFloat) pBlue Alpha:(CGFloat) pAlpha;
@end
