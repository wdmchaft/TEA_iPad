//
//  Session.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Session : NSObject 
{
    NSString *sessionName;
    NSString *sessionGuid;
    NSString *sessionTeacherName;
    NSString *sessionLectureName;
    NSString *sessionLectureGuid;
    NSString *dateInfo;
    
    NSString *quizPromptTitle;
    NSString *quizPromptBGColor;
    NSString *quizPromptTextColor;
    NSString *quizPromptOKTitle;
    NSString *quizPromptCancelTitle;
}

@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSString *sessionGuid;
@property (nonatomic, retain) NSString *sessionTeacherName;
@property (nonatomic, retain) NSString *sessionLectureName;
@property (nonatomic, retain) NSString *sessionLectureGuid;
@property (nonatomic, retain) NSString *dateInfo;


@property (nonatomic, retain) NSString *quizPromptTitle;
@property (nonatomic, retain) NSString *quizPromptBGColor;
@property (nonatomic, retain) NSString *quizPromptTextColor;
@property (nonatomic, retain) NSString *quizPromptOKTitle;
@property (nonatomic, retain) NSString *quizPromptCancelTitle;


@end
