//
//  DWViewItemText.h
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWViewItem.h"

@interface DWViewItemLlibraryItemClip : DWViewItem 
{
    UIWebView *webField;
    NSString *path;
    NSString *htmlString;  
}

@property (nonatomic, retain) NSString *htmlString; 

@end
