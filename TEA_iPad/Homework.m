//  Sync.m
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "Homework.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

#import "LocalDatabase.h"
#import "TEA_iPadAppDelegate.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "BonjourService.h"
#import "ConfigurationManager.h"

#import "Reachability.h"

#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import "ZipWriteStream.h"
#import "LibraryHomeworkItem.h"
#import "Sync.h"
#import "DeviceLog.h"


@implementation Homework
@synthesize dictionary, libraryViewController, globalSync;


- (NSString*) getDeviceLogMessages
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSString *sql =[NSString stringWithFormat:@"select * from device_log where device_id = '%@'", [appDelegate getDeviceUniqueIdentifier]];
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql];
    NSString *returnValue = [[CJSONSerializer serializer] serializeArray:result];
    return [NSString stringWithFormat:@"{'device_log':%@}", returnValue];
}


- (void) postDeviceLog
{
     
    NSString *deviceLogURL = [NSString stringWithFormat: @"%@/deviceLog.jsp", [ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_URL"]]; 
    
    NSURLResponse *response = nil;
    NSError **error=nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:deviceLogURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
    
    NSData *tmpData = [[[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]] autorelease];
    
    if(response)
    {
        @try 
        {   
            NSString *systemMessges = [self getDeviceLogMessages];
            
            
            NSString *requestURL = [NSString stringWithFormat:@"device_log=%@", systemMessges];
            
            
            NSData *postData = [requestURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
            
            NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:deviceLogURL]]];
            
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
            [request setHTTPBody:postData];
            
            NSData *deviceLogFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            
            NSString *checkString = [[[NSString alloc] initWithData:deviceLogFileData encoding:NSUTF8StringEncoding] autorelease];
            checkString = [checkString substringToIndex:2];
            
            if ([checkString isEqualToString:@"OK"]) {
                NSLog(@"Device Log alındı...");
                [[LocalDatabase sharedInstance] executeQuery:@"delete from device_log;"];
           }
            else
                NSLog(@"Device Log sending error.");
            
        }
        @catch (NSException *exception) 
        {
            NSLog(@"Exception :: %@",  [exception description]);
        }
    }
}


- (void) insertHomeworkAnswers
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString *questionAnswersURL = [NSString stringWithFormat: @"%@/homeworkAnswers.jsp?device_id=%@", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"], [appDelegate getDeviceUniqueIdentifier]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:questionAnswersURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
    
    NSData *homeworkAnswerData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    
    NSDictionary *homeworkAnswersDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:homeworkAnswerData error:nil];
    NSArray *homeworkAnswers = [homeworkAnswersDictionary objectForKey:@"answers"];
    
    
    for(NSDictionary *answer in homeworkAnswers)
    {
              
        
        NSString *insertSql = [NSString stringWithFormat: @"insert into homework_answer ('homework','question','answer','correct_answer','time') values ('%@','%@','%@','%@','%@')", [answer objectForKey:@"homework"], [answer objectForKey:@"question"], [answer objectForKey:@"answer"], [answer objectForKey:@"correct_answer"], [answer objectForKey:@"time"]];
        
        [[LocalDatabase sharedInstance] executeQuery:insertSql];
    }
    [homeworkAnswerData release];
}


- (NSString*) getSystemMessages
{
    NSString *sql = @"select guid from homework";
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql returnSimpleArray:YES];
    
    NSString *returnValue = [[CJSONSerializer serializer] serializeArray:result];
    
    
    return [NSString stringWithFormat:@"{'system_messages': %@ }", returnValue];
}


- (NSString*) getSystemMessagesOfUndeliveredHomework:(NSString *)filter
{
    NSString *sql =[NSString stringWithFormat:@"select * from homework_answer where homework = '%@'", filter];
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql];
    NSString *returnValue = [[CJSONSerializer serializer] serializeArray:result];
    return [NSString stringWithFormat:@"{'homework_answers':%@}", returnValue];
}


- (void) postHomeworkFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSString *sql = @"select * from homework";
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql];
    
    
    for (int i=0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] valueForKey:@"delivered"] intValue] == -1) {
            NSLog(@"%d", i);
            
            NSString *homeworkURL = [NSString stringWithFormat: @"%@/homeworkResult.jsp", [ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_URL"]]; 
            
            NSURLResponse *response = nil;
            NSError **error=nil;
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:homeworkURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
            
            NSData *tmpData = [[[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]] autorelease];
            
            if(response)
            {
                @try 
                {   
                    NSString *systemMessges = [self getSystemMessagesOfUndeliveredHomework:[[result objectAtIndex:i] objectForKey:@"guid"]];
                    
                    NSString *totalTime = [[result objectAtIndex:i] objectForKey:@"total_time"];
                    
                    NSString *requestURL = [NSString stringWithFormat:@"device_id=%@&homework_id=%@&homework_answers=%@&total_time=%@", [appDelegate getDeviceUniqueIdentifier], [[result objectAtIndex:i] objectForKey:@"guid"], systemMessges, totalTime];
                    
                    
                    NSData *postData = [requestURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                    
                    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
                    
                    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
                    
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:homeworkURL]]];
                    
                    [request setHTTPMethod:@"POST"];
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
                    [request setHTTPBody:postData];
                    
                    NSData *homeworkFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    
                    
                    NSString *checkString = [[[NSString alloc] initWithData:homeworkFileData encoding:NSUTF8StringEncoding] autorelease];
                    checkString = [checkString substringToIndex:2];
                    
                    if ([checkString isEqualToString:@"OK"]) 
                    {
                        [[LocalDatabase sharedInstance] executeQuery:[NSString stringWithFormat:@"update homework set delivered = 1 where guid = '%@'", [[result objectAtIndex:i] objectForKey:@"guid"]]];
                        NSLog(@"%@ guid'li ödevin gönderim işlemi tamamlandı. Sıradaki ödev kontrol ediliyor...", [[result objectAtIndex:i] valueForKey:@"guid"]);
                    }
                    else
                    {
                        NSLog(@"Homework sending error...");
                        NSLog(@"%@", checkString);
                    }
                        
                    
                }
                @catch (NSException *exception) 
                {
                    NSLog(@"Exception :: %@",  [exception description]);
                }
            }
        }
        else{
            if ([[[result objectAtIndex:i] valueForKey:@"delivered"] intValue] == 1) {
                NSLog(@"Gönderilmiş ödev: %@", [[result objectAtIndex:i] valueForKey:@"guid"]);
            }
            else
                NSLog(@"Sonlandırılmamış ödev: %@", [[result objectAtIndex:i] valueForKey:@"guid"]);
        }
    }
}


- (void) downloadHomeworkFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    if(dictionary)
    {
        
        NSArray *files = [dictionary objectForKey:@"files"];
        
        if(currentFileIndex < [files count])
        {
            NSDictionary *file = [files objectAtIndex:currentFileIndex];
            
            fileName = [file valueForKey:@"file"];
            fileSize = [[file valueForKey:@"filesize"] intValue];
            
            NSString *homeworkFileBaseURL = [ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_URL"]; 
            NSString *downloadURL = [NSString stringWithFormat: @"%@/%@", homeworkFileBaseURL, fileName];
            
            //NSLog(@"[SYNC] downloadingFile : %@", downloadURL);
            
            NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
            [request setURL:  [NSURL URLWithString:downloadURL]];
            [request setHTTPMethod:@"GET"];
            
            NSMutableDictionary *headerFields = [[NSMutableDictionary alloc] init];
            [headerFields setObject:@"Keep-Alive" forKey:@"Connection"];
            
            [request setAllHTTPHeaderFields:headerFields];
            [headerFields release];
            
            
            NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
            
            if (theConnection) 
            {
                downloadData = [[NSMutableData data] retain];
            } 
        }
        else
        {
            [self insertHomeworkAnswers];
            [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];    
        }
        
    }
    else
    {
        [self insertHomeworkAnswers];
        [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];    

    }
    
}

- (void) requestForHomework
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
    BOOL homeworkEnabled = [[ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
    
    NSString *homeworkURL = [NSString stringWithFormat: @"%@/homework.jsp", [ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:homeworkURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
    
    NSData *tmpData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    NSLog(@"after homework connect");
    
    if(homeworkEnabled && response)
    {
        @try 
        {   
            [globalSync updateMessage:@"Ev ödevleri yükleniyor..."];
            
            fileSize = 0;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *lastSyncTime = [defaults objectForKey:@"lastSyncTime"];
            
            if(!lastSyncTime)
            {
                lastSyncTime = @"1900-01-01";
            }
            
            NSString *systemMessges = [self getSystemMessages];
            
            NSString *downloadURL = [NSString stringWithFormat: @"system_messages=%@&device_id=%@&start_date_time=%@", systemMessges, [appDelegate getDeviceUniqueIdentifier], lastSyncTime];
            
            //NSLog(@"[SYNC] %@", downloadURL);
            
            //  downloadURL = [downloadURL stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
            
            NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
            
            NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:homeworkURL]]];
            
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
            [request setHTTPBody:postData];
            
            NSData *homeworkFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            dictionary = [[[CJSONDeserializer deserializer] deserializeAsDictionary:homeworkFileData error:nil] retain];
            
            [self postDeviceLog];
            
            [self postHomeworkFile];
            
            [self downloadHomeworkFile];
            
            
        }
        @catch (NSException *exception) 
        {
            //NSLog(@"Exception :: %@",  [exception description]);
            [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];    

        }
    }
    else
    {
        [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];    
    }
    
    [tmpData release];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];    
}



- (void)dealloc {
    [dictionary release];
    [fileName release];
    [super dealloc];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    [downloadData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [downloadData appendData:data];
    [globalSync updateProgress:[NSNumber numberWithFloat:(float) downloadData.length / (float) fileSize]];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSDictionary *file = [[dictionary objectForKey:@"files"] objectAtIndex:currentFileIndex];
    
    NSString *dateOfExam = [file valueForKey:@"date"];
    NSString *date = [[dateOfExam componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSArray *components = [date componentsSeparatedByString:@"-"];
    NSString *dateString = [NSString stringWithFormat:@"%@.%@.%@", [components objectAtIndex:2], [components objectAtIndex:1], [components objectAtIndex:0]];
    
    
    // create dummy session
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.session.sessionGuid = [file valueForKey:@"guid"];
    appDelegate.session.sessionName = [file valueForKey:@"name"];
    appDelegate.session.dateInfo = dateString;
    appDelegate.session.sessionLectureGuid = [file valueForKey:@"lecture_id"];
    appDelegate.session.sessionLectureName = [file valueForKey:@"lecture_name"];
    
    [globalSync updateProgress:[NSNumber numberWithFloat:1.0]];
    
    // save into documents path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //   NSString *directoryPath = [[NSString stringWithFormat:@"%@/%@", documentsDir, [[fileName componentsSeparatedByString:@"."] objectAtIndex:0] ] retain];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    //  [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [downloadData writeToFile:filePath atomically:YES];
    
    
    LibraryHomeworkItem *libraryHomeworkItem = [[LibraryHomeworkItem alloc] init];
    libraryHomeworkItem.guid = [file valueForKey:@"guid"];
    libraryHomeworkItem.name = @"Ödev";
    libraryHomeworkItem.path = [file valueForKey:@"file"];
    
    [libraryHomeworkItem saveLibraryItem];
    // download next file
    [libraryHomeworkItem release];
    
    currentFileIndex++;
    
    
    // save homework
    
    
    NSString *insertSQL = @"INSERT INTO homework (guid, lecture_id, name, type, date, file, delivered, total_time) VALUES ('%@', '%d', '%@', 0, '%@', '%@', '%@', '%@')";
    
    insertSQL = [NSString stringWithFormat:insertSQL, [file valueForKey:@"guid"], [[file valueForKey:@"lecture_id"] intValue], [file valueForKey:@"name"], dateString, [file valueForKey:@"file"], [file valueForKey:@"delivered"], [file valueForKey:@"time"]];
    
    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
    
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
    
    [self downloadHomeworkFile];
    
    
}

@end


