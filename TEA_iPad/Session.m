//
//  Session.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "Session.h"


@implementation Session
@synthesize sessionGuid, sessionName, sessionLectureGuid, sessionLectureName, sessionTeacherName, dateInfo;

- (id) init
{
    self = [super init];
    
    if(self)
    {

    }
    
    return self;
}

- (void)dealloc 
{
    [dateInfo release];
    [sessionGuid release];
    [sessionLectureGuid release];
    [sessionLectureName release];
    [sessionName release];
    [sessionTeacherName release];
    
    [super dealloc];
}

@end
