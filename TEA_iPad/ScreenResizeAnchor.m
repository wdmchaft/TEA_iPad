//
//  ScreenResizeAnchor.m
//  tea
//
//  Created by Oguz Demir on 21/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "ScreenResizeAnchor.h"


@implementation ScreenResizeAnchor
@synthesize anchorPosition, viewToResize, containerView;

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) setActionSelector:(SEL) pSelector forTarget:(id)pTarget
{
    actionSelector = pSelector;
    target = pTarget;
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    startPoint = location;
    startSize = YES;
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(startSize)
    {
        UITouch *touch = [touches anyObject];
        CGPoint newMouseLocation = [touch locationInView:self];
        
        CGPoint delta = CGPointMake( newMouseLocation.x - startPoint.x,
                                    newMouseLocation.y - startPoint.y);
        
        CGRect newFrame = [viewToResize frame];
        
        if([self tag] == kAnchorMove)
        {
            newFrame.origin.y += delta.y;
            newFrame.origin.x += delta.x;
        }
        else
        if([self tag] == kAnchorPositionNorth)
        {   
            newFrame.origin.y += delta.y;
           // newFrame.size.height += delta.y;
        }
        else if([self tag] == kAnchorPositionSouth)
        {
            newFrame.origin.y += delta.y;
          //  newFrame.size.height -= delta.y;
        }
        else if([self tag] == kAnchorPositionWest)
        {
            newFrame.origin.x += delta.x;
            newFrame.size.width -= delta.x;
        }
        else if([self tag] == kAnchorPositionEast)
        {
            newFrame.size.width += delta.x;
        }
        else if([self tag] == kAnchorPositionNorthWest)
        {
            newFrame.size.height += delta.y;
            newFrame.origin.x += delta.x;
            newFrame.size.width -= delta.x;
        }
        else if([self tag] == kAnchorPositionSouthWest)
        {
            newFrame.origin.y += delta.y;
            newFrame.size.height -= delta.y;
            newFrame.origin.x += delta.x;
            newFrame.size.width -= delta.x;
        }
        else if([self tag] == kAnchorPositionNorthEast)
        {
            newFrame.origin.y += delta.y;
            newFrame.size.height -= delta.y;
            newFrame.size.width += delta.x;
        }
        else if([self tag] == kAnchorPositionSouthEast)
        {
            newFrame.size.height += delta.y;
            newFrame.size.width += delta.x;
        }
        
       
        CGRect rect = CGRectMake(containerView.frame.origin.x - 250, containerView.frame.origin.y, containerView.frame.size.width + 250, containerView.frame.size.height + 250);
        if(CGRectContainsRect(rect, newFrame))
        {
            [viewToResize setFrame:newFrame];
        }
        
        if([self tag] != kAnchorMove)
        {
            
           // startPoint = newMouseLocation;
        }
        
        
        [target performSelector:actionSelector];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    startSize = NO;
    
    [target performSelector:actionSelector];
}



@end
