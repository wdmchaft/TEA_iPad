//
//  DWViewItem.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWViewItem.h"
#import <QuartzCore/QuartzCore.h>
#import "LocalDatabase.h"
#import "DWObjectView.h"
#import "TEA_iPadAppDelegate.h"

@implementation DWViewItem
@synthesize lineColor, lineWidth, lineStyle, fillColor, font, transparency, scale, rotate, flip, itemState, viewObject, selected, guid, container;



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) //ok
    {
        [container removeViewItem:self];
    }
}



- (void) closeClicked
{
    
    NSString *alertString = NSLocalizedString(@"Object Delete Message", NULL);
    NSString *cancel = NSLocalizedString(@"Cancel", NULL);
    NSString *delete = NSLocalizedString(@"Delete", NULL);
    NSString *caution = NSLocalizedString(@"Caution", NULL);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:caution message:alertString delegate:self cancelButtonTitle:cancel otherButtonTitles: delete, nil];
    
    [alertView show];
    
    
    
    
}

- (void) setContainer:(DWObjectView *)aContainer
{
    container = aContainer;
    moveAnchor.containerView = container;
    southEastAnchor.containerView = container;
}

- (void) initViewItem
{
    selected = NO;
    
    self.guid = [LocalDatabase stringWithUUID];
    
    moveAnchor = [[ScreenResizeAnchor alloc] initWithFrame:CGRectMake(15, self.bounds.size.width - 30, 25,  25)];
    [moveAnchor setBackgroundColor:[UIColor clearColor]];
    [moveAnchor setImage:[UIImage imageNamed:@"AnchorMove.jpg"]];
    moveAnchor.tag = kAnchorMove;
    moveAnchor.viewToResize = self;
    [moveAnchor setActionSelector:@selector(resized) forTarget:self];
    [self addSubview:moveAnchor];
    [moveAnchor release];
    
    southEastAnchor = [[ScreenResizeAnchor alloc] initWithFrame:CGRectMake(self.frame.size.width - 28, self.frame.size.height - 28, 28,  28)];
    [southEastAnchor setBackgroundColor:[UIColor clearColor]];
    southEastAnchor.tag = kAnchorPositionSouthEast;
    southEastAnchor.viewToResize = self;
    [southEastAnchor setImage:[UIImage imageNamed:@"AnchorResize.png"]];
    [southEastAnchor setActionSelector:@selector(resized) forTarget:self];
    [self addSubview:southEastAnchor];
    [southEastAnchor release];
    
    closeAnchor = [[ScreenResizeAnchor alloc] initWithFrame:CGRectMake(self.frame.size.width - 28, 0, 28,  28)];
    [closeAnchor setBackgroundColor:[UIColor clearColor]];
    closeAnchor.tag = kAnchorUnused;
    [closeAnchor setImage:[UIImage imageNamed:@"AnchorClose.png"]];
    [closeAnchor setActionSelector:@selector(closeClicked) forTarget:self];
    [self addSubview:closeAnchor];
    [closeAnchor release];
}

- (void) setSelected:(BOOL)pSelected
{
    selected = pSelected;
    [moveAnchor setHidden:!pSelected];
    [southEastAnchor setHidden:!pSelected];
    [closeAnchor setHidden:!pSelected];
    
    if(pSelected)
    {
        [viewObject.layer setBorderWidth:1.0];
        [viewObject.layer setCornerRadius:3.0];
        [viewObject.layer setMasksToBounds:YES];
    }
    else
    {
        [viewObject.layer setBorderWidth:0.0];
        [viewObject.layer setCornerRadius:0.0];
        [viewObject.layer setMasksToBounds:NO];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self initViewItem];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self initViewItem];
    }
    return self;
}

- (void) resized
{
    [viewObject setFrame:CGRectMake(15, 40, self.bounds.size.width - 30, self.bounds.size.height - 55)];
    
    [moveAnchor setFrame:CGRectMake(15, 15, self.bounds.size.width - 30,  40)];
    [southEastAnchor setFrame:CGRectMake(self.frame.size.width - 28, self.frame.size.height - 28, 28,  28)];
    [closeAnchor setFrame:CGRectMake(self.frame.size.width - 28, 0, 28,  28)];
}

- (void)dealloc
{
    [guid dealloc];
    [super dealloc];
}

- (NSString *) getXML { return nil; }

- (NSString *) getPosition
{
    CGRect frame = self.frame;
    NSString *position = [NSString stringWithFormat:@"%f,%f,%f,%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height]; 
    return position;
}

- (CGRect) getPositionByString:(NSString *)aPositionString
{
    NSArray *components = [aPositionString componentsSeparatedByString:@","];
    
    CGRect position = CGRectNull;
    position.origin.x = [[components objectAtIndex:0] floatValue];
    position.origin.y = [[components objectAtIndex:1] floatValue]; 
    position.size.width = [[components objectAtIndex:2] floatValue];
    position.size.height = [[components objectAtIndex:3] floatValue];
    
    return position;
}

@end
