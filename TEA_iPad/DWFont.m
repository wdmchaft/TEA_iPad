//
//  DWFont.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWFont.h"


@implementation DWFont

@synthesize faceName;
@synthesize size;
@synthesize style;



- (void)dealloc 
{
    [faceName release];
    [style release];
    
    [super dealloc];
}

@end
