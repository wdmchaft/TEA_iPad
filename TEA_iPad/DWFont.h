//
//  DWFont.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWAttribute.h"

@interface DWFont : DWAttribute 
{
    NSString *faceName;
    CGFloat size;
    NSString *style;
}

@property (nonatomic, retain) NSString *faceName;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, retain) NSString *style;


@end
