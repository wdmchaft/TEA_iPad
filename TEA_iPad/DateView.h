//
//  DateView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 10/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryView;
@interface DateView : UIView 
{
    UIImageView *selection;
    UIImageView *numbers;
    LibraryView *controller;
    
    
}

@property (nonatomic, assign) LibraryView *controller;

- (void) selectDate:(int) aSelectedDate;

@end
