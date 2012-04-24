//
//  NumericPad.h
//  TEA_iPad
//
//  Created by Oguz Demir on 31/10/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

enum kButtonTags 
{
    kButton0        = 0,
    kButton1        = 1,
    kButton2        = 2,
    kButton3        = 3,
    kButton4        = 4,
    kButton5        = 5,
    kButton6        = 6,
    kButton7        = 7,
    kButton8        = 8,
    kButton9        = 9,
    kButtonOK       = 10,
    kButtonDelete   = 50,
} ;

@class AdminPanel;
@interface NumericPad : UIViewController
{
    UIPopoverController *popup;
    UIPopoverController *adminPanel;
}

@property (retain, nonatomic) UIPopoverController *adminPanel;
@property (retain, nonatomic) IBOutlet UITextField *textField;
@property (retain, nonatomic) IBOutlet UIPopoverController *popup;


- (IBAction) buttonClicked:(UIButton*)sender;

@end
