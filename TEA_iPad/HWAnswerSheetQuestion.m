//
//  HWAnswerSheetQuestion.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "HWAnswerSheetQuestion.h"
#import "HWAnswerSheet.h"
#import "HWView.h"
#import "LocalDatabase.h"
#import "TEA_iPadAppDelegate.h"

@implementation HWAnswerSheetQuestion
@synthesize answerView, markupImage, isDark, isSelected, number, optionCounter, indexOfQuestion, totalNumberQuestion, answerSheet, coverView, dataDictionary, currentHomework, selectedOption, correctAnswer;



- (void) finishedExamAnswerSheet:(NSString*)givenAnswer
{
    
/*    
    NSString *sql = [NSString stringWithFormat:@"select answer from homework_answer where homework = '%@' and question = '%@'", currentHomework, [dataDictionary objectForKey:@"number"]];
    
    NSArray *resultArray = [[LocalDatabase sharedInstance] executeQuery:sql];
    NSString *givenAnswer = nil;
    if (resultArray && [resultArray count] > 0) {
        givenAnswer = [[resultArray objectAtIndex:0] valueForKey:@"answer"];
    }
   
*/    
    
    buttonArray = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((i+1)*44, 6, 40, 40)];
        [button setTitleColor:[UIColor colorWithRed:133.0 / 255.0 green:82.0 / 255.0 blue:82.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        
        
        if (!givenAnswer || [givenAnswer isEqualToString:@" "] || [givenAnswer isEqualToString:@""]) 
        {
            if (i==0){
                if ([correctAnswer isEqualToString:@"A"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"a" forState:UIControlStateNormal];
            }
            else if (i==1){
                if ([correctAnswer isEqualToString:@"B"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                [button setTitle:@"b" forState:UIControlStateNormal];
            }
            else if (i==2){
                if ([correctAnswer isEqualToString:@"C"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                [button setTitle:@"c" forState:UIControlStateNormal];
            }
            else if (i==3){
                if ([correctAnswer isEqualToString:@"D"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                [button setTitle:@"d" forState:UIControlStateNormal];
            }
            else if (i==4){
                if ([correctAnswer isEqualToString:@"E"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                [button setTitle:@"e" forState:UIControlStateNormal];
            }
        }
        
        else if ([correctAnswer isEqualToString:givenAnswer]) 
        {
            if (i==0){
                if ([correctAnswer isEqualToString:@"A"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"a" forState:UIControlStateNormal];
            }
            else if (i==1){
                if ([correctAnswer isEqualToString:@"B"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                
                [button setTitle:@"b" forState:UIControlStateNormal];
            }
            else if (i==2){
                if ([correctAnswer isEqualToString:@"C"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                
                [button setTitle:@"c" forState:UIControlStateNormal];
            }
            else if (i==3){
                if ([correctAnswer isEqualToString:@"D"]) 
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                
                [button setTitle:@"d" forState:UIControlStateNormal];
            }
            else if (i==4){
                if ([correctAnswer isEqualToString:@"E"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }  
                else
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                
                [button setTitle:@"e" forState:UIControlStateNormal];
            }
        }
        else if (![correctAnswer isEqualToString:givenAnswer])
        {
            if (i==0){
                if ([correctAnswer isEqualToString:@"A"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else if([givenAnswer isEqualToString:@"A"]){
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"a" forState:UIControlStateNormal];
            }
            else if (i==1){
                if ([correctAnswer isEqualToString:@"B"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else if ([givenAnswer isEqualToString:@"B"]){
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"b" forState:UIControlStateNormal];
            }
            else if (i==2){
                if ([correctAnswer isEqualToString:@"C"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else if ([givenAnswer isEqualToString:@"C"]){
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"c" forState:UIControlStateNormal];
            }
            else if (i==3){
                if ([correctAnswer isEqualToString:@"D"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else if ([givenAnswer isEqualToString:@"D"]){
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"d" forState:UIControlStateNormal];
            }
            else if (i==4){
                if ([correctAnswer isEqualToString:@"E"])
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionCorrectAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else if ([givenAnswer isEqualToString:@"E"]){
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionWrongAnswer.png"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                }
                
                [button setTitle:@"e" forState:UIControlStateNormal];
            }
        }
        
        
        [button setTag:i+1];
        [buttonArray addObject:button];
        [self addSubview:[buttonArray objectAtIndex:i]];
        [button release];

    }
    
    if (optionCounter == 4) {
        [[buttonArray objectAtIndex:optionCounter] setHidden:YES];
    }
}




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        answerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 265, 52)];
        UIColor *backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"HWAnswerSheetQuestionDarkBG.png"]] autorelease];
        [self setBackgroundColor:backgroundColor];
        
        markupImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [markupImage setImage:[UIImage imageNamed:@"HWAnswerSheetQuestionMarker.png"]];
        [markupImage setHidden:YES];
        
        [self addSubview:markupImage];
        
        NSString *givenAnswer = nil;
        NSString *sql = [NSString stringWithFormat:@"select answer from homework_answer where homework = '%@' and question = '%@'", currentHomework, [dataDictionary objectForKey:@"number"]];
        
        NSArray *resultArray = [[LocalDatabase sharedInstance] executeQuery:sql];
        if (resultArray && [resultArray count] > 0) {
            givenAnswer = [[resultArray objectAtIndex:0] valueForKey:@"answer"];
        }
        
        if (self.answerSheet.mainView.delivered == 0) {
            // Get answer for the question

            buttonArray = [[NSMutableArray alloc] init];
            for (int i=0; i<5; i++) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((i+1)*44, 6, 40, 40)];
                
                
                [button setTitleColor:[UIColor colorWithRed:133.0 / 255.0 green:82.0 / 255.0 blue:82.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
                
                if (i==0){
                    if ([givenAnswer isEqualToString:@"A"]) 
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionSelectedBG.png"] forState:UIControlStateNormal];
                    else
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                        
                    [button setTitle:@"a" forState:UIControlStateNormal];
                }
                else if (i==1){
                    if ([givenAnswer isEqualToString:@"B"]) 
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionSelectedBG.png"] forState:UIControlStateNormal];
                    else
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                    
                    [button setTitle:@"b" forState:UIControlStateNormal];
                }
                else if (i==2){
                    if ([givenAnswer isEqualToString:@"C"]) 
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionSelectedBG.png"] forState:UIControlStateNormal];
                    else
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                    
                    [button setTitle:@"c" forState:UIControlStateNormal];
                }
                else if (i==3){
                    if ([givenAnswer isEqualToString:@"D"]) 
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionSelectedBG.png"] forState:UIControlStateNormal];
                    else
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                    
                    [button setTitle:@"d" forState:UIControlStateNormal];
                }
                else if (i==4){
                    if ([givenAnswer isEqualToString:@"E"]) 
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionSelectedBG.png"] forState:UIControlStateNormal];
                    else
                        [button setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                    
                    [button setTitle:@"e" forState:UIControlStateNormal];
                }
                
             
                [button setTag:i+1];
                [button addTarget:self action:@selector(answerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [buttonArray addObject:button];
                [self addSubview:[buttonArray objectAtIndex:i]];
                [button release];

            }
            
            if (optionCounter == 4) {
                [[buttonArray objectAtIndex:optionCounter] setHidden:YES];
            }
        }
        else {
            NSDictionary *currentAnswerDict;
            
            if (self.answerSheet.mainView.cloneExamAnswers && [self.answerSheet.mainView.cloneExamAnswers count] > 0) 
            {
                for (NSDictionary *dict in self.answerSheet.mainView.cloneExamAnswers) 
                {
                    if ([[dataDictionary objectForKey:@"number"]intValue] == [[dict objectForKey:@"soru_no"] intValue]) {
                        currentAnswerDict = dict;
                    }
                }  
                correctAnswer = [currentAnswerDict objectForKey:@"yansima_cevap"];
            }
            else {
                
                correctAnswer = @"";
            }
                        
            [self finishedExamAnswerSheet:givenAnswer];
        }
            
            
            
        UIButton *questionNumber = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 52)] autorelease];
        [questionNumber setBackgroundColor:[UIColor clearColor]];
        [questionNumber setTitle:[NSString stringWithFormat:@"%d.", [self tag]] forState:UIControlStateNormal];
        [questionNumber setTitleColor:[UIColor colorWithRed:133.0 / 255.0 green:82.0 / 255.0 blue:82.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [questionNumber addTarget:self action:@selector(quesitonNumberClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:questionNumber];
        
        
        CGRect coverViewRect = CGRectMake(37, 0, self.bounds.size.width - 37, self.bounds.size.height);
        
        self.coverView = [[[UIView alloc] initWithFrame:coverViewRect] autorelease];
        [self.coverView setBackgroundColor:[UIColor blackColor]];
        [self.coverView setAlpha:0.3];
        
        [self addSubview:self.coverView];
    
    }
    return self;
}


- (IBAction)answerButtonClicked:(id)sender
{
    

    for (int i=0; i<[buttonArray count]; i++) {
        if ([[buttonArray objectAtIndex:i] tag] != [sender tag]) 
        {
            [[buttonArray objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
        }
        else
        {
            
            NSString *homeworkName = [[currentHomework componentsSeparatedByString:@"."] objectAtIndex:0];
            
            NSString *getSelectedOption = [NSString stringWithFormat:@"select answer from homework_answer where question = '%@' and homework = '%@'", [dataDictionary valueForKey:@"number"], homeworkName];
            
            NSArray *rows = [[LocalDatabase sharedInstance] executeQuery:getSelectedOption];
            
            if ([rows count]>0 && ![rows isEqual:[NSNull null]]) {
                
                NSString *str = [[rows objectAtIndex:0] objectForKey:@"answer"];
                if (str){
                    str = [str isEqualToString:@""] ? @" " : str;
                    int charValueOfString = (int)[str characterAtIndex:0];
                    if (charValueOfString > 64 || charValueOfString <= 69){
                        selectedOption = charValueOfString-65;
                    }
                    else{
                        selectedOption = -1;
                    }
                }
            }
            else
                selectedOption=-1;
            
            if (selectedOption == [sender tag]-1) {
                selectedOption = -1;
                [[buttonArray objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionBG.png"] forState:UIControlStateNormal];
                
                
            }
            else{
                selectedOption = [sender tag]-1;
                [[buttonArray objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"HWAnswerSheetQuestionOptionSelectedBG.png"] forState:UIControlStateNormal];
            }
            
            NSString *selectSql = [NSString stringWithFormat:@"select * from homework_answer where question = '%@' and homework = '%@'", [dataDictionary valueForKey:@"number"], homeworkName];
            
            
            NSArray *getAllQuestionValues = [[LocalDatabase sharedInstance] executeQuery:selectSql];
            
            NSString *deleteSql;
            if ([getAllQuestionValues count]>0 && ![getAllQuestionValues isEqual:[NSNull null]]) {
                deleteSql = [NSString stringWithFormat:@"delete from homework_answer where question = '%@' and homework = '%@'", [dataDictionary valueForKey:@"number"], homeworkName];
                
                [[LocalDatabase sharedInstance] executeQuery:deleteSql];
                
            }
            
            NSString *buttonText;
            
            if (selectedOption != -1) {
                buttonText = [sender currentTitle];
            }
            else{
                buttonText = @" ";
            }
            
            HWAnswerSheetQuestion *question = (HWAnswerSheetQuestion*)[sender superview];
            HWView *mainView = question.answerSheet.mainView;
            
            NSString *insertSql;
            if ([getAllQuestionValues count]>0 && ![getAllQuestionValues isEqual:[NSNull null]]) {
                insertSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, answer, correct_answer, time) values ('%@', '%@', '%@', '%@', '%d')", homeworkName, [dataDictionary valueForKey:@"number"], [buttonText uppercaseString], [dataDictionary valueForKey:@"correctAnswer"], [mainView getCurrentQuestionTimer]];
            }
            else{

                insertSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, answer, correct_answer, time) values ('%@', '%@', '%@', '%@', '%d')", homeworkName, [dataDictionary valueForKey:@"number"], [buttonText uppercaseString], [dataDictionary valueForKey:@"correctAnswer"], [mainView getCurrentQuestionTimer]];
            }
            [[LocalDatabase sharedInstance] executeQuery:insertSql];
            
            
        }
    }

    
    
}



- (IBAction)quesitonNumberClicked:(id)sender
{
    
    HWAnswerSheetQuestion *question = (HWAnswerSheetQuestion*)[sender superview];
    HWView *mainView = question.answerSheet.mainView;
/*    
    NSString *select = [NSString stringWithFormat:@"select time from homework_answer where homework = '%@' and question = '%d'", mainView.homeworkGuid, question.tag];
    
    NSArray *allHWansTable = [[LocalDatabase sharedInstance] executeQuery:select];
    int questionTimers=0;
    
    if ([allHWansTable count]>0 && ![allHWansTable isEqual:[NSNull null]]) {
        questionTimers = [[[allHWansTable objectAtIndex:0] objectForKey:@"time"] intValue];
    }
    
    [mainView.questionTimer setCurrentSecond:questionTimers];
*/    
    [mainView showQuestion:question.tag];
    
    //[answerSheet selectQuestion:question.tag];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [markupImage release];
    [buttonArray release];
    [answerView release];
    [super dealloc];
}

@end
