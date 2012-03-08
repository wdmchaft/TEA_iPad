//
//  ActivityIndicator.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 06.03.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActivityIndicator
@synthesize indicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];    
        [self.layer setCornerRadius:10];
        
        
        self.indicator = [[[UIActivityIndicatorView alloc] 						   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        
        
        
        self.indicator.frame = self.bounds;
        
        [self addSubview:self.indicator];
    }
    return self;
}


- (void)dealloc {
    [indicator release];
    [super dealloc];
}
@end
