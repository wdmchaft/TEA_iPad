//
//  LibraryItem.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LibraryItem.h"
#import "LibraryView.h"


@implementation LibraryItem
@synthesize type, creationDate, modificationDate, sessionName, name, path, serverPath, extension, guid ;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [guid release];
    [extension release];
    [serverPath release];
    [name release];
    [path release];
    [creationDate release];
    [modificationDate release];
    [sessionName release];
    [super dealloc];
}

- (void) saveLibraryItem
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    /* CREATE SESSION IF NOT EXISTS */
    NSString *session_guid = appDelegate.session.sessionGuid;
    NSString *session_name = appDelegate.session.sessionName;
    NSString *session_date = appDelegate.session.dateInfo;
    NSString *lecture_guid = appDelegate.session.sessionLectureGuid;
    
    NSString *selectSql = [NSString stringWithFormat:@"select session_guid from session where session_guid = '%@'", session_guid];
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:selectSql];
    
    if(!(result && [result count] > 0))
    {
        NSString *insertSQL = @"insert into session(lecture_guid, date, session_guid, name) values ('%@', '%@', '%@', '%@')";
        insertSQL = [NSString stringWithFormat:insertSQL, lecture_guid, session_date, session_guid, session_name];
        
        [[LocalDatabase sharedInstance] executeQuery:insertSQL];
    }
    
    
    
    
    /* CREATE LECTURE IF NOT EXISTS */
    NSString *lecture_name = appDelegate.session.sessionLectureName;

    selectSql = [NSString stringWithFormat:@"select lecture_name from lecture where lecture_name = '%@'", lecture_name];
    result = [[LocalDatabase sharedInstance] executeQuery:selectSql];

    if(!(result && [result count] > 0))
    {
        NSString *insertSQL = @"insert into lecture(lecture_guid, lecture_name) values ('%@', '%@')";
        insertSQL = [NSString stringWithFormat:insertSQL, lecture_guid, lecture_name];
        
        [[LocalDatabase sharedInstance] executeQuery:insertSQL];
    }
    
        

    
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(initLectureNames) withObject:nil waitUntilDone:YES]; 

}

@end
