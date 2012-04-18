//
//  LocalDatabase.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LocalDatabase.h"


@implementation LocalDatabase

//static NSMutableArray *sharedInstances;
static LocalDatabase *sharedInstance;

+ (NSString*) stringWithUUID {
    CFUUIDRef	uuidObj = CFUUIDCreate(NULL);//create a new UUID
    //get the string representation of the UUID
    
    CFStringRef uuidRef = CFUUIDCreateString(NULL, uuidObj);
    
      
    NSString *uuidString = (NSString*)  CFStringCreateCopy(NULL, uuidRef);
    CFRelease(uuidRef);
    CFRelease(uuidObj);
    
    return [uuidString autorelease] ;
}


- (void) openDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databaseName = @"library.sqlite";
	NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = (NSString*) [documentPaths objectAtIndex:0];
    
    
    if(![fileManager fileExistsAtPath:documentsDir])
    {
        [fileManager createDirectoryAtPath:documentsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    
	BOOL success = [fileManager fileExistsAtPath:databasePath];
	
	if(success)
    {
        // NSLog(@"DB FOUND");
    }
    else
    {
        //    NSLog(@"DB NOT FOUND");
        //    NSLog(@"Trying to copy resource db");
        
        NSString *databasePathFromApp = [[NSBundle mainBundle] pathForResource:@"library" ofType:@"sqlite"];
        
        
        
        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    }
    
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
        // Check userlog table
        NSString *userLogTableCheck = @"SELECT name FROM sqlite_master WHERE name='userlog'";
        NSArray *userLogTableResult = [self executeQuery:userLogTableCheck];
        if(!userLogTableResult || [userLogTableResult count] <= 0)
        {
            NSString *messageTableCreate = @"CREATE TABLE userlog (deviceid TEXT, system_version TEXT, version TEXT, session_name TEXT, session_guid TEXT, battery_life TEXT, message TEXT, log TEXT);";
            [self executeQuery:messageTableCreate];
        }
        
        // Check system messages table
        NSString *systemMessagesCheck = @"SELECT name FROM sqlite_master WHERE name='system_messages'";
        NSArray *systemMessagesTableResult = [self executeQuery:systemMessagesCheck];
        if(!systemMessagesTableResult || [systemMessagesTableResult count] <= 0)
        {
            NSString *systemMessagesCreate = @"CREATE TABLE system_messages (guid TEXT, date TEXT, type TEXT, deleted TEXT);";
            [self executeQuery:systemMessagesCreate];
        }
        else {
            NSString *systemMessagesAlterTable = @"ALTER TABLE system_messages ADD deleted CHAR(25) NULL;";
            [self executeQuery:systemMessagesAlterTable];
            
            NSString *updateSystemMessages = @"update system_messages set deleted='0' where deleted is NULL";
            [self executeQuery:updateSystemMessages];
            
        }
        
        // Check homework table
        NSString *homeworkTableCheck = @"SELECT name FROM sqlite_master WHERE name='homework'";
        NSArray *homeworkTableResult = [self executeQuery:homeworkTableCheck];
        if(!homeworkTableResult || [homeworkTableResult count] <= 0)
        {
            NSString *homeworkTableCreate = @"CREATE TABLE homework (guid TEXT, lecture_id TEXT, name TEXT, type TEXT, date TEXT, file TEXT, delivered TEXT, total_time TEXT);";
            [self executeQuery:homeworkTableCreate];
        }
        else {
            NSString *homeworkTableCreate = @"ALTER TABLE homework ADD deleted CHAR(25) NULL;";
            [self executeQuery:homeworkTableCreate];
        }
        
        
        // Check homework asnwers table
        NSString *homeworkAnswersCheck = @"SELECT name FROM sqlite_master WHERE name='homework_answer'";
        NSArray *homeworkAnswerTableResult = [self executeQuery:homeworkAnswersCheck];
        if(!homeworkAnswerTableResult || [homeworkAnswerTableResult count] <= 0)
        {
            NSString *homeworkAnswerTableCreate = @"CREATE TABLE homework_answer (homework TEXT, question TEXT, answer TEXT, correct_answer TEXT, time TEXT);";
            [self executeQuery:homeworkAnswerTableCreate];
        }
        else {
            NSString *homeworkAnswerAlterTable = @"ALTER TABLE homework_answer ADD time CHAR(25) NULL;";
            [self executeQuery:homeworkAnswerAlterTable];
        }
            
        
        // Check Device Log table
        NSString *deviceLogTableCheck = @"SELECT name FROM sqlite_master WHERE name='device_log'";
        NSArray *deviceLogTableResult = [self executeQuery:deviceLogTableCheck];
        if (!deviceLogTableResult || [deviceLogTableResult count]<= 0) 
        {
            NSString *deviceLogTableCreate = @"CREATE TABLE device_log (device_id TEXT, system_version TEXT, version TEXT, key TEXT, lecture TEXT, content_type TEXT, time TEXT, data TEXT, lat TEXT, long TEXT );";
            [self executeQuery:deviceLogTableCreate];
        }
        else {
            NSString *deviceLogAlterTable = @"ALTER TABLE device_log ADD duration CHAR(25) NULL;";
            [self executeQuery:deviceLogAlterTable];
            deviceLogAlterTable = @"ALTER TABLE device_log ADD guid char(255);";
            [self executeQuery:deviceLogAlterTable];
            deviceLogAlterTable = @"ALTER TABLE device_log ADD session_name char(255);";
            [self executeQuery:deviceLogAlterTable];
        }
        
        
        
        //Check Calendar table
        NSString *calendarTableCheck = @"SELECT name FROM sqlite_master WHERE name='calendar'";
        NSArray *calendarTableResult = [self executeQuery:calendarTableCheck];
        
        if (!calendarTableResult || [calendarTableResult count]<=0) 
        {
            NSString *calendarTableCreate = @"CREATE TABLE calendar (id TEXT, type TEXT, title TEXT, body TEXT, image_name TEXT, image_url TEXT, date_time TEXT, valid_date_time TEXT, alarm_date_time TEXT, repeated TEXT, completed TEXT, homework_ref_id TEXT, alarm_state TEXT, deleted TEXT);";
            [self executeQuery:calendarTableCreate];
        }
        
        // NSLog(@"DB OPENED");
	}
    else
    {
        //    NSLog(@"DB NOT OPENED");
    }
}

+ (LocalDatabase*) sharedInstance
{
    
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance = [[LocalDatabase alloc] init];
            [sharedInstance openDatabase];
        }
        
        return sharedInstance;
    }
    
    
    
    return nil;
}




- (id)init
{
    self = [super init];
    if (self) {
        database = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) closeDatabase
{
    sqlite3_close(database);
}

int rowCallBack(void *a_param, int argc, char **argv, char **column)
{
    for (int i=0; i< argc; i++)
        printf("%s,\t", argv[i]);
    printf("\n");
    
    return 0;
}


- (NSMutableArray*) executeQuery:(NSString*)pQuery
{
    @synchronized(self)
    {
        if(!database)
        {
            [self openDatabase];
        }
        
        sqlite3_stmt *compiledStatement;
        
        int result = sqlite3_prepare_v2(database, [pQuery UTF8String], -1, &compiledStatement, NULL);
        
        if(result == SQLITE_OK) 
        {
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            
            //  NSLog(@"running sql = %@", pQuery);
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) 
            {
                NSMutableDictionary *columns = [[NSMutableDictionary alloc] init];
                int columnCount = sqlite3_column_count(compiledStatement);
                for( int i=0; i < columnCount; i++)
                {
                    NSString *columnName  = [NSString stringWithCString:sqlite3_column_name(compiledStatement, i) encoding:NSUTF8StringEncoding];
                    NSString *columnValue = @"";
                    const char* columnSqlValue = (const char*)sqlite3_column_text(compiledStatement, i);
                    if(columnSqlValue)
                    {
                        columnValue = [NSString stringWithCString:(const char*)sqlite3_column_text(compiledStatement, i) encoding:NSUTF8StringEncoding];
                    }
                    
                    [columns setValue:columnValue forKey:columnName];
                    
                }
                [returnArray addObject:columns];
                [columns release];
            }
            
            sqlite3_finalize(compiledStatement);
            
            return [returnArray autorelease];
        }
        else 
        {
            NSLog(@"query not performed error code %d", result);
        }
    }
    
    
    return nil;
}


- (NSMutableArray*) executeQuery:(NSString*)pQuery returnSimpleArray:(BOOL) returnSimpleArray
{
    @synchronized(self)
    {
        if(!database)
        {
            [self openDatabase];
        }
        
        sqlite3_stmt *compiledStatement;
        
        int result = sqlite3_prepare_v2(database, [pQuery UTF8String], -1, &compiledStatement, NULL);
        
        if(result == SQLITE_OK) 
        {
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) 
            {
                // NSMutableDictionary *columns = [[NSMutableDictionary alloc] init];
                int columnCount = sqlite3_column_count(compiledStatement);
                for( int i=0; i < columnCount; i++)
                {
                    // NSString *columnName  = [NSString stringWithCString:sqlite3_column_name(compiledStatement, i) encoding:NSUTF8StringEncoding];
                    NSString *columnValue = @"";
                    const char* columnSqlValue = (const char*)sqlite3_column_text(compiledStatement, i);
                    if(columnSqlValue)
                    {
                        columnValue = [NSString stringWithCString:(const char*)sqlite3_column_text(compiledStatement, i) encoding:NSUTF8StringEncoding];
                    }
                    
                    //[columns setValue:columnValue forKey:columnName];
                    [returnArray addObject:columnValue];
                }
                //[returnArray addObject:columns];
                //[columns release];
            }
            
            sqlite3_finalize(compiledStatement);
            return [returnArray autorelease];
        }
        else 
        {
            NSLog(@"query not performed error code %d", result);
        }
    }
    
    return nil;
}

@end
