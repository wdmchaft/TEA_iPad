//
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

@implementation Homework
@synthesize dictionary, libraryViewController;
@synthesize globalSync;

- (NSString*) getSystemMessages
{
    
    
    NSString *sql = @"select guid from homework";
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql returnSimpleArray:YES] ;
    
    NSString *returnValue = [[CJSONSerializer serializer] serializeArray:result];
    
    
    return [NSString stringWithFormat:@"{'system_messages': %@ }", returnValue];
}



- (void) downloadHomeworkFile
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    self.dictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSMutableDictionary *file = [[NSMutableDictionary alloc] init];
    [file setValue:@"2012-01-14" forKey:@"date"];
    [file setValue:@"5635749E-6E08-4084-9CFF-03572369E9A7" forKey:@"guid"];
    [file setValue:@"SBS - Örnek Sorular" forKey:@"name"];
    [file setValue:@"a43c5c85-f654-48fe-9ad1-f083046e34bc" forKey:@"lecture_id"];
    [file setValue:@"Matematik" forKey:@"lecture_name"];
    [file setValue:@"650F1977-7646-4A4E-8EF1-116DAAB88A5F.zip" forKey:@"file"];
    [file setValue:@"340997" forKey:@"filesize"];
    
    NSMutableArray *files = [[NSMutableArray alloc] init];
    [files addObject:file];
    [file release];
    
    [dictionary setValue:files forKey:@"files"];
    [files release];
    
    if(dictionary)
    {
        
        NSArray *files = [dictionary objectForKey:@"files"];
        
        if(currentFileIndex < [files count])
        {
            NSDictionary *file = [files objectAtIndex:currentFileIndex];
            
            fileName = [file valueForKey:@"file"];
            fileSize = [[file valueForKey:@"filesize"] intValue];
            
            NSString *homeworkFileBaseURL = @"http://www.terrabilgiislem.com/tea/homework"; 
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
             [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];
            
        }
        
    }
    else
    {
        [appDelegate.viewController startSyncService:kSyncServiceTypeNotebookSync];

        
    }
    
}


- (void) requestForHomework
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
    BOOL homeworkEnabled = [[ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
    
    NSString *homeworkURL = [NSString stringWithFormat: @"http://www.terrabilgiislem.com/tea", [ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:homeworkURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];

    
    if(homeworkEnabled && response)
    {
        @try 
        {          
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
    [progressView setProgress: (float) downloadData.length / (float) fileSize];
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
    
    
    [progressView setProgress:1.0];
    
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
    
    
    NSString *insertSQL = @"INSERT INTO homework (guid, lecture_id, name, type, date, file, delivered, total_time) VALUES ('%@', '%d', '%@', 0, '%@', '%@', '%@', '0')";
    
    insertSQL = [NSString stringWithFormat:insertSQL, [file valueForKey:@"guid"], [[file valueForKey:@"lecture_id"] intValue], [file valueForKey:@"name"], dateString, [file valueForKey:@"file"], [file valueForKey:@"delivered"]];
    
    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
    
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
    
    [self downloadHomeworkFile];
    
    
}

@end
