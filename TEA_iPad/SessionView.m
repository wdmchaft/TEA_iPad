//
//  SessionView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "SessionView.h"
#import "LocalDatabase.h"
#import "SessionLibraryItemView.h"
#import "LibraryView.h"

@implementation SessionView
@synthesize sessionName, sessionGuid, libraryViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) insertContents
{
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db openDatabase];
    
    NSArray *result = [db executeQuery: [NSString stringWithFormat:@"select guid, name, path, type, quizImagePath, previewPath, quizCorrectAnswer, quizAnswer from library where session_guid = '%@'", sessionGuid]];
    
    int counter = 0;
    int x,y;
    CGRect sessionItemViewRect = CGRectNull;
    
    for(NSDictionary *resultDict in result)
    {
        
        
        
        if(libraryViewController.compactMode)
        {
            x = ((counter % 5) * 51) ;
            y = ((counter / 5) * 55) + 30;
            sessionItemViewRect = CGRectMake(x, y, 41, 55);
        }
        else
        {
            x = ((counter % 5) * 135) + 20;
            y = ((counter / 5) * 150) + 30;
            sessionItemViewRect = CGRectMake(x, y, 103, 130);
        }

        SessionLibraryItemView *sessionItemView = [[SessionLibraryItemView alloc] initWithFrame:sessionItemViewRect];
        sessionItemView.sessionView = self;
        sessionItemView.guid = [resultDict valueForKey:@"guid"];
        
        sessionItemView.name = [resultDict valueForKey:@"name"];
        sessionItemView.path = [resultDict valueForKey:@"path"];
        sessionItemView.type = [resultDict valueForKey:@"type"];
        sessionItemView.quizImagePath = [resultDict valueForKey:@"quizImagePath"];
        sessionItemView.previewPath = [resultDict valueForKey:@"previewPath"];
        sessionItemView.correctAnswer = [[resultDict valueForKey:@"quizCorrectAnswer"] intValue];
        sessionItemView.answer = [[resultDict valueForKey:@"quizAnswer"] intValue];
        
        [self addSubview:sessionItemView];
        [sessionItemView initLibraryItemView];
        [sessionItemView release];
        counter++;
    }

    [db closeDatabase];
    [db release];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, sessionItemViewRect.origin.y + sessionItemViewRect.size.height + 20);
}

- (void) initSessionView
{

    sessionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
    
    if(libraryViewController.compactMode)
    {
        [sessionNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    }
    else
    {
        [sessionNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    }
    
    [sessionNameLabel setBackgroundColor:[UIColor clearColor]];
    [sessionNameLabel setTextColor:[UIColor whiteColor]];
    [sessionNameLabel setText:sessionName];
    [sessionNameLabel setTextAlignment:UITextAlignmentCenter];
    
    [self addSubview:sessionNameLabel];
    
    [self setBackgroundColor:[UIColor colorWithRed:109.0/255.0 green:36.0/255.0 blue:35.0/255.0 alpha:0.5]];
    
    [self insertContents];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [sessionGuid release];
    if(sessionNameLabel)
        [sessionNameLabel release];
    [sessionName release];
    [super dealloc];
}

@end
