//
//  HWAnswerSheet.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "HWAnswerSheet.h"
#import "HWAnswerSheetQuestion.h"
#import "HWParser.h"
#import "HWView.h"

@implementation HWAnswerSheet

@synthesize parsedDictionary, answerSheetView, currentQuestion, mainView, homeworkGuid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int numberOfQuestion = [[parsedDictionary objectForKey:@"questions"] count]; 
        
        self.contentSize =  CGSizeMake(frame.size.width, 55*numberOfQuestion);
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"HWAnswerSheetBG.png"]]];
        int yCoord = 1;
        for (int i=0; i<numberOfQuestion; i++) {
            HWAnswerSheetQuestion *answerSheetQuestion =[HWAnswerSheetQuestion alloc];
            answerSheetQuestion.optionCounter = [[[[parsedDictionary objectForKey:@"questions"] objectAtIndex:i] objectForKey:@"optionCount"] intValue];
            answerSheetQuestion.tag = i+1;
            answerSheetQuestion.indexOfQuestion = currentQuestion;
            answerSheetQuestion.totalNumberQuestion = numberOfQuestion;
            answerSheetQuestion.answerSheet = self;
            answerSheetQuestion.dataDictionary = [[parsedDictionary objectForKey:@"questions"] objectAtIndex:i];
            answerSheetQuestion.currentHomework = homeworkGuid;
            
            
            [answerSheetQuestion initWithFrame:CGRectMake(0, yCoord, 265, 55)];
            [self addSubview:answerSheetQuestion];
            [answerSheetView release];
            yCoord += 55;

        }
   }
   return self;
}

- (void) selectQuestion:(int) questionIndex
{

    int homeworkDeliveredValue = mainView.delivered;
    
    for (UIView *answerQuestion in self.subviews) 
    {
        if ([answerQuestion isKindOfClass:[HWAnswerSheetQuestion class]]) 
        {
            HWAnswerSheetQuestion *question = (HWAnswerSheetQuestion*) answerQuestion ;
            
            if(question.tag == questionIndex)
            {
                [question.markupImage setHidden:NO];
                if(homeworkDeliveredValue == kHomeworkDeliveredNormal)
                {
                    [question.coverView setHidden:YES];
                }
                else
                {
                    [question.coverView setHidden:NO];
                }
            }
            else
            {
                [question.markupImage setHidden:YES];
                [question.coverView setHidden:NO];
            }
        }
        
    }
    
}



@end
