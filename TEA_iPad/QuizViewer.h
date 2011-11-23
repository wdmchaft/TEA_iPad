//
//  QuizViewer.h
//  TEA_iPad
//
//  Created by Oguz Demir on 7/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuizViewer : UIViewController {
    
    UIButton *answerA;
    UIButton *answerB;
    UIButton *answerC;
    UIButton *answerD;
    UIButton *answerE;
    
    int answer;
    int correctAnswer;
    UIWebView *quizImage;
    
}
@property (nonatomic, retain) IBOutlet UIButton *answerA;
@property (nonatomic, retain) IBOutlet UIButton *answerB;
@property (nonatomic, retain) IBOutlet UIButton *answerC;
@property (nonatomic, retain) IBOutlet UIButton *answerD;
@property (nonatomic, retain) IBOutlet UIButton *answerE;

@property (nonatomic, assign) int answer;
@property (nonatomic, assign) int correctAnswer;
@property (nonatomic, retain) IBOutlet UIWebView *quizImage;
@property (retain, nonatomic) IBOutlet UIImageView *quizImageView;

- (void) setupView;
- (UIImage *) captureImage;

@end
