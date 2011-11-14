//
//  DWObjectView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWObjectView.h"


@implementation DWObjectView
@synthesize viewItems;

- (void) initObjectView
{
    viewItems = [[NSMutableArray alloc] init];
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

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initObjectView];
    }
    return self;
}

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
    for(DWViewItem *viewItem in viewItems)
    {
        [viewItem setSelected:selected];
    }
}

- (void) removeViewItem:(DWViewItem *) aViewItem
{
    [aViewItem removeFromSuperview];
    [viewItems removeObject:aViewItem];
    
}

- (void) addViewItem:(DWViewItem*) viewItem
{
    [viewItems addObject:viewItem];
    viewItem.container = self;
    [self addSubview:viewItem];
    [viewItem setFrame:CGRectMake(150, 150, 300, 300)];
 }

- (void)dealloc
{
    [viewItems release];
    [super dealloc];
}

@end
