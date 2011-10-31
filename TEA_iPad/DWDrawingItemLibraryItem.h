//
//  DWDrawingItemRectangle.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDrawingItem.h"

@class LibraryItem;
@interface DWDrawingItemLibraryItem : DWDrawingItem <UITextViewDelegate>
{
    UITextView *textField;
    BOOL drawTextField;
    
    NSString *text;
    UIImage *textFieldImage;
    
    LibraryItem *item;
    
}

@property (nonatomic, retain) NSString *text;

- (void) setTextFieldImage:(UIImage*) pImage;

@end
