//
//  DWViewItemText.h
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWViewItem.h"

@interface DWViewItemWebClip : DWViewItem 
{
    NSString *htmlString;    
    UIWebView *webField;
}

@property (nonatomic, retain) NSString *htmlString; 

@end
