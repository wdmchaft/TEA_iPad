//
//  HWAnswerSheet.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWView;
@interface HWAnswerSheet : UIScrollView
{
    NSMutableDictionary *parsedDictionary;
    UIScrollView *answerSheetView;
    HWView *mainView;
    
    int currentQuestion;
    NSString *homeworkGuid;
}

- (void) selectQuestion:(int) questionIndex;

@property (nonatomic, retain) UIScrollView *answerSheetView;
@property (nonatomic, retain) NSMutableDictionary *parsedDictionary;
@property (nonatomic, assign) HWView *mainView;
@property (nonatomic, assign) int currentQuestion;
@property (nonatomic, retain) NSString *homeworkGuid;

@end
