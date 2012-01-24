


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

- (NSString*) getSystemMessages
{

    
    NSString *sql = @"select guid from homework";
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql returnSimpleArray:YES] ;
    
    NSString *returnValue = [[CJSONSerializer serializer] serializeArray:result];

    
    return [NSString stringWithFormat:@"{'system_messages': %@ }", returnValue];
}

- (void) startSyncingAfterHomework
{
    NSLog(@"**** starting sync service");
    
    libraryViewController.syncView = [[Sync alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [libraryViewController.syncView setHidden:YES];
    [libraryViewController.view addSubview:libraryViewController.syncView];
    [libraryViewController.syncView requestForSync];
    [libraryViewController.syncView release];
    
}

- (void) downloadHomeworkFile
{

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
            [self setHidden:YES];
            [self startSyncingAfterHomework];
            //[appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
        }
        
    }
    else
    {
        [self setHidden:YES];
        [self startSyncingAfterHomework];
        //[appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
    }
    
}





- (void) requestForHomework
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [self setHidden:NO];
    
    // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
    BOOL homeworkEnabled = [[ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
    
    NSString *homeworkURL = [NSString stringWithFormat: @"%@/homework.jsp", [ConfigurationManager getConfigurationValueForKey:@"HOMEWORK_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:homeworkURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    NSData *tmpData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    
    
    if(homeworkEnabled && response)
    {
        @try 
        {   
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

            
            [self downloadHomeworkFile];
        }
        @catch (NSException *exception) 
        {
            //NSLog(@"Exception :: %@",  [exception description]);
            [self startSyncingAfterHomework];
            [self setHidden:YES];
        }
    }
    else
    {
        [self setHidden:YES];
        [self startSyncingAfterHomework];
    }
    
    [tmpData release];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setHidden:YES];
    [self startSyncingAfterHomework];

}



- (void)dealloc {
    [dictionary release];
    [fileName release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [imageView setImage:[UIImage imageNamed:@"HomeworkBG.jpg"]];
        [self addSubview:imageView];
        
        
        
        progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(100, 480, 824, 25)] autorelease];
        [self addSubview:progressView];
        
        progressLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 480, 1024, 25)] autorelease];
        [progressLabel setTextColor:[UIColor whiteColor]];
        [progressLabel setTextAlignment:UITextAlignmentCenter];
        //  [self addSubview:progressLabel]; 
        
        
    }
    return self;
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


