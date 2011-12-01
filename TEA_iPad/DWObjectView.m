//
//  DWObjectView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWObjectView.h"
#import "DWDrawingViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation DWObjectView
@synthesize drawingViewController;

- (void) initObjectView
{
  // viewItems = [[NSMutableArray alloc] init];
    self.clipsToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initObjectView];
    }
    return self;
}

- (UIImage*) screenImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    
    return anImage;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initObjectView];
    }
    return self;
}
/*
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if([touch tapCount] == 2)
    {
        [drawingViewController.editModeSwitch setOn:NO];
        [drawingViewController editModeOnOffChanged:drawingViewController.editModeSwitch];
    }
}*/


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setAllSelected:(BOOL) selected
{
    for(DWViewItem *viewItem in self.subviews)
    {
        [viewItem setSelected:selected];
    }
}

/*
- (void) removeViewItem:(DWViewItem *) aViewItem
{
    [aViewItem removeFromSuperview];
    [viewItems removeObject:aViewItem];
    
}
*/

- (void) addViewItem:(DWViewItem*) viewItem
{
  //  [viewItems addObject:viewItem];
    viewItem.container = self;
    [self addSubview:viewItem];
 }

- (void)dealloc
{
  //  [viewItems release];
    [super dealloc];
}

@end
