//
//  MonthView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 10/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryView;
@interface MonthView : UILabel 
{    
    int year;
    int month;
    
    BOOL selected;
    LibraryView *viewController;

}

@property (nonatomic, assign) int year;
@property (nonatomic, assign) int month;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) LibraryView *viewController;


@end
