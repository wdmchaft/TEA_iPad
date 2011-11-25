//
//  LibraryVideoItem.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LibraryVideoItem.h"


@implementation LibraryVideoItem

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
    [super dealloc];
}

- (void) saveLibraryItem
{
    [super saveLibraryItem];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db openDatabase];
    
    /* CREATE SESSION IF NOT EXISTS */
    NSString *session_guid = appDelegate.session.sessionGuid;
    
    NSString *insertSQL = @"insert into library(guid, session_guid, name, path, type) values ('%@', '%@', '%@', '%@', 'video')";
    insertSQL = [NSString stringWithFormat:insertSQL, self.guid, session_guid, self.name, self.path];
    
    [db executeQuery:insertSQL];
    
    [db closeDatabase];
    [db release];
 
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
}

@end
