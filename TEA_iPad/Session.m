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
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:today];
        
        self.dateInfo = dateString;
        [dateFormatter release];
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
