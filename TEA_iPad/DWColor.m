//
//  DWColor.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWColor.h"


@implementation DWColor


@synthesize redColorValue;
@synthesize greenColorValue;
@synthesize blueColorValue;
@synthesize alphaColorValue;

- (id) init
{
    self = [super init];
    
    redColorValue = 0;
    greenColorValue = 0;
    blueColorValue = 0;
    alphaColorValue = 1;
    
    return self;
}

-(void) setColorWithColors:(CGFloat) pRed Green:(CGFloat)pGreen  Blue:(CGFloat) pBlue Alpha:(CGFloat) pAlpha
{
    redColorValue = pRed;
    greenColorValue = pGreen;
    blueColorValue = pBlue;
    alphaColorValue = pAlpha;
}
@end
