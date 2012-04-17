//
//  HWView.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWAnswerSheet.h"
#import "HWParser.h"
#import "Timer.h"



enum kHomeworkDelivered {
    kHomeworkDeliveredFinished = -1,
    kHomeworkDeliveredNormal = 0,
    kHomeworkDeliveredSentToServer = 1
    };

@interface HWView : UIView 
{
    HWParser *parser;
    
    UIView *backGroundView;
    UIView *hwView;
    
    UILabel *titleOfHomework;
    //UIWebView *questionView;
    UIImageView *questionView;
    UIButton *prevQuestion;
    UIButton *nextQuestion;
    
    UIButton *closeButton;
    UIButton *finishButton;
    Timer *timer;
    
    //**************
    // timer eklendi
    Timer *questionTimer;
    //**********************
    
    HWAnswerSheet *answerSheetView;
    
    NSString *questionImageURL;
    
    int currentQuestion;
    
    NSString *zipFileName;
    NSString *homeworkGuid;
    
    int delivered;
    
    
    int previousQuestionNumber;
    NSMutableArray *cloneExamAnswers;
    NSMutableData *downloadData;
}


@property (nonatomic, retain) NSMutableArray *cloneExamAnswers;

@property (nonatomic, assign) Timer *questionTimer;


- (id)initWithFrame:(CGRect)frame andZipFileName:(NSString*) aZipFileName andHomeworkId:(NSString*) aHomeworkGUID;

@property (nonatomic, assign) HWAnswerSheet *answerSheetView;
@property (nonatomic, retain) HWParser *parser;

@property (nonatomic, retain) NSString *questionImageURL;
@property (nonatomic, retain) Timer *timer;
@property (nonatomic, assign) int currentQuestion;
@property (nonatomic, assign) int delivered;
@property (nonatomic, retain) NSString *zipFileName;
@property (nonatomic, retain) UILabel *titleOfHomework;
@property (nonatomic, retain) NSString *homeworkGuid;

- (void) showQuestion:(int) questionIndex;
- (int) getCurrentQuestionTimer;
- (void) extractZipFile;

@end
