//
//  DWObjectView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWViewItem.h"

@interface DWObjectView : UIView 
{
    NSMutableArray *viewItems;
}

- (void) addViewItem:(DWViewItem*) viewItem;
- (void) setAllSelected:(BOOL) selected;
- (void) removeViewItem:(DWViewItem *) aViewItem;

@property (nonatomic, assign) NSMutableArray *viewItems;

@end
