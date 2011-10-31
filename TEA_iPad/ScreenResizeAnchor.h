//
//  ScreenResizeAnchor.h
//  tea
//
//  Created by Oguz Demir on 21/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

enum kAnchorPositions {
    kAnchorUnused = -5,
    kAnchorPositionNorth = 0,
    kAnchorPositionWest = 1,
    kAnchorPositionSouth = 2,
    kAnchorPositionEast = 3,
    kAnchorPositionNorthWest = 4,
    kAnchorPositionSouthWest = 5,
    kAnchorPositionNorthEast = 6,
    kAnchorPositionSouthEast = 7,
    kAnchorMove              = 10
    };


@interface ScreenResizeAnchor : UIImageView {
@private
    
    int anchorPosition;
    bool startSize;
    CGPoint startPoint;
    
    UIView *containerView;
    UIView *viewToResize;
    id target;
    SEL actionSelector;
}

@property (assign) int anchorPosition;
@property (assign) UIView *viewToResize;
@property (assign) UIView *containerView;

- (void) setActionSelector:(SEL) pSelector forTarget:(id)pTarget;

@end
