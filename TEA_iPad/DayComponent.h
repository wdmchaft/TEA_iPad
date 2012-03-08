//
//  DayComponent.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayComponent : UIView
{
    NSDate *currentDay;
    
    
    int fontSize;
    int viewWitdh;
    int viewHight;
    UIColor *backGroundColor;
    UIColor *textColor;
    NSString *fontType;
    
    
}

@property (nonatomic, retain) NSDate *currentDay;



@property (nonatomic, assign) int fontSize;
@property (nonatomic, assign) int viewWitdh;
@property (nonatomic, assign) int viewHight;
@property (nonatomic, retain) UIColor *backGroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) NSString *fontType;



- (void) setCurrentDateDayLabel:(NSDate *)aCurrentDate;

@end
