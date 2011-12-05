//
//  LocalDatabase.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LocalDatabase.h"


@implementation LocalDatabase

+ (NSString*) stringWithUUID {
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
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
       // NSLog(@"DB OPENED");
	}
    else
    {
    //    NSLog(@"DB NOT OPENED");
    }
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
    if(!database)
    {
        [self openDatabase];
    }
        
    const char *sqlStatement = [pQuery UTF8String];
    sqlite3_stmt *compiledStatement;
    
    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) 
    {
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        

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
        NSLog(@"query not performed");
    }
    
    return nil;
}



@end
