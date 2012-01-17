//
//  HWAnswerSheetQuestion.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWAnswerSheet;
@interface HWAnswerSheetQuestion : UIView
{
    BOOL isDark;
    BOOL isSelected;
    
    int number;
    int optionCounter;
    
    UIView *answerView;
    HWAnswerSheet *answerSheet;
    
    NSMutableArray *buttonArray;
    UIImageView *markupImage;
    
    
    int indexOfQuestion;
    int totalNumberQuestion;
    
    UIView *coverView;
    
    NSDictionary *dataDictionary;
    NSString *currentHomework;
    
}


@property (nonatomic, retain) UIImageView *markupImage;
@property (nonatomic, retain) UIView *answerView;
@property (nonatomic, assign) HWAnswerSheet *answerSheet;
@property (nonatomic, assign) BOOL isDark;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int optionCounter;
@property (nonatomic, assign) int indexOfQuestion;
@property (nonatomic, retain) UIView *coverView;

@property (nonatomic, assign) int totalNumberQuestion;

@property (nonatomic, retain) NSDictionary *dataDictionary;

@property (nonatomic, retain) NSString *currentHomework;

@end
