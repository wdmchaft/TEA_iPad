//
//  DWDrawingItemRectangle.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDrawingItem.h"

@interface DWDrawingItemTyping : DWDrawingItem <UITextViewDelegate>
{
    UITextView *textField;
    BOOL drawTextField;
    
    NSString *text;
    UIImage *textFieldImage;
    DWColor *textColor;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) DWColor *textColor;

- (void) setTextFieldImage:(UIImage*) pImage;

@end
