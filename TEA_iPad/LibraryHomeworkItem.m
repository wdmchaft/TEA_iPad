//
//  LibraryQuizItem.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LibraryHomeworkItem.h"


@implementation LibraryHomeworkItem
@synthesize quizType, quizReference, quizExpType, quizOptCount, quizSolveTime, quizAnswer, quizCorrectAnswer, quizImagePath, quizSolutionVideoPath, totalViewTime;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void) saveLibraryItem
{
    [super saveLibraryItem];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    /* CREATE SESSION IF NOT EXISTS */
    NSString *session_guid = appDelegate.session.sessionGuid;
    
    NSString *selectSql = [NSString stringWithFormat:@"select guid from library where guid = '%@'", self.guid];
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:selectSql];
    
    if(!(result && [result count] > 0))
    {
        NSString *insertSQL = @"insert into library(guid, session_guid, name, path, type, quizImagePath, quizAnswer, quizCorrectAnswer, quizExpType, quizOptCount) values ('%@', '%@', '%@', '%@', 'homework', '%@', %d, -1, '%d', '%d')";
        insertSQL = [NSString stringWithFormat:insertSQL, self.guid, session_guid, self.name, self.path, self.quizImagePath, self.quizAnswer, self.quizExpType, self.quizOptCount];
        
        [[LocalDatabase sharedInstance] executeQuery:insertSQL];
        
        
        
        [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
    }
 
}

- (void)dealloc
{
    [quizImagePath release];
    [quizSolutionVideoPath release];
    [super dealloc];
}

@end
