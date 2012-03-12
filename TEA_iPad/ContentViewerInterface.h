//
//  ContentViewerInterface.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/3/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum kContentViewOpenDirection {
    kContentViewOpenDirectionToLeft = 0,
    kContentViewOpenDirectionToRight = 1,
    kContentViewOpenDirectionNormal = 1
    } ContentViewOpenDirection;

@protocol ContentViewerInterface <NSObject>

- (void) closeContentViewWithDirection :(ContentViewOpenDirection)direction;;
- (void) loadContentView:(UIView *)view withDirection :(ContentViewOpenDirection)direction;

@end
