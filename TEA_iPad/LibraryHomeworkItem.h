//
//  LibraryQuizItem.h
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibraryItem.h"

@interface LibraryHomeworkItem : LibraryItem 
{
@private
    
    int quizType;
    int quizReference;
    int quizExpType;
    int quizOptCount;
    int quizSolveTime;
    int quizAnswer;
    int quizCorrectAnswer;
    NSString *quizImagePath;
    NSString *quizSolutionVideoPath;
    
    int totalViewTime;

}

@property (nonatomic, assign) int quizType;
@property (nonatomic, assign) int quizReference;
@property (nonatomic, assign) int quizExpType;
@property (nonatomic, assign) int quizOptCount;
@property (nonatomic, assign) int quizSolveTime;
@property (nonatomic, assign) int quizAnswer;
@property (nonatomic, assign) int quizCorrectAnswer;
@property (nonatomic, retain) NSString *quizImagePath;
@property (nonatomic, retain) NSString *quizSolutionVideoPath;

@property (nonatomic, assign) int totalViewTime;

@end
