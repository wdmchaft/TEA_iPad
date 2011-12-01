//
//  Quiz.h
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timer.h"

@interface Quiz : UIViewController {
    
    UILabel *timerLabel;
    UIWebView *quizImage;
    UIButton *answerA;
    UIButton *answerB;
    UIButton *answerC;
    UIButton *answerD;
    UIButton *answerE;
    UIView *timerView;
    int solveTime;
    UIView *bgView;
    Timer *timerControl;
    NSString *guid;
    BOOL displayMode;
    
    int currentAnswer;
    int correctAnswer;
    int optionCount;
    int quizExpType;
    
    UIImage *image;
}

@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, retain) IBOutlet UIWebView *quizImage;
@property (nonatomic, retain) IBOutlet UIButton *answerA;
@property (nonatomic, retain) IBOutlet UIButton *answerB;
@property (nonatomic, retain) IBOutlet UIButton *answerC;
@property (nonatomic, retain) IBOutlet UIButton *answerD;
@property (nonatomic, retain) IBOutlet UIButton *answerE;
@property (nonatomic, assign) int solveTime;
@property (nonatomic, assign) int quizExpType;
@property (nonatomic, assign) int optionCount;
@property (nonatomic, retain) IBOutlet UIView *bgView;
@property (nonatomic, retain) IBOutlet Timer *timerControl;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, assign) BOOL displayMode;
@property (nonatomic, assign) int correctAnswer;
@property (nonatomic, retain) IBOutlet UIView *timerView;
@property (nonatomic, retain) UIImage *image;

- (IBAction)answerAClicked:(id)sender;
- (IBAction)answerBClicked:(id)sender;
- (IBAction)answerCClicked:(id)sender;
- (IBAction)answerDClicked:(id)sender;
- (IBAction)answerEClicked:(id)sender;

- (void) timeIsOver;
- (void) updateCorrectAnswer;
- (void) saveQuizItem;

@end
