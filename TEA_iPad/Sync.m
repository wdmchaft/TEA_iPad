//
//  Sync.m
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "Sync.h"
#import "CJSONDeserializer.h"
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


@implementation Sync

- (void) requestForSync
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    previousState = appDelegate.state;
    appDelegate.state = kAppStateSyncing;
    [self setHidden:NO];
    
   // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
    BOOL syncEnabled = [[ConfigurationManager getConfigurationValueForKey:@"SYNC_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
    
    NSString *syncURL = [NSString stringWithFormat: @"%@/sync.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    

    if(syncEnabled && response)
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
            
            
             NSString *downloadURL = [NSString stringWithFormat: @"%@?device_id=%@&start_date_time=%@", syncURL, [appDelegate getDeviceUniqueIdentifier], lastSyncTime];
             
            NSLog(@"[SYNC] %@", downloadURL);
            
             downloadURL = [downloadURL stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
             NSData *syncFileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadURL]];
             
             NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:syncFileData error:nil];
             
             if(dictionary)
             {
             if([[dictionary valueForKey:@"name"] length] > 0)
             {
             fileName = [[dictionary valueForKey:@"name"] retain];
             fileSize = [[dictionary valueForKey:@"size"] intValue];
             fileList = [[dictionary objectForKey:@"files"] retain];
             [defaults setObject:[dictionary objectForKey:@"syncTime"] forKey:@"lastSyncTime"];
             [defaults synchronize];
             } 
             
             [self downloadSyncFile];
             }
             else
             {
             [self setHidden:YES];
             appDelegate.state = previousState;
             [appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
             }
            
            
        }
        @catch (NSException *exception) 
        {
            NSLog(@"Exception :: %@",  [exception description]);
            [self setHidden:YES];
            appDelegate.state = previousState;
        }
    }
    else
    {
        [self setHidden:YES];
        appDelegate.state = previousState;
        [appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];

    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    NSLog(@"timout");
    [self setHidden:YES];
    appDelegate.state = previousState;
    [appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
}

- (void) downloadSyncFile
{
//    NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
    
    NSString *syncFileBaseURL = [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]; //[iPadConfigDictionary valueForKey:@"syncFileDownloadURL"];
    NSString *downloadURL = [NSString stringWithFormat: @"%@/%@", syncFileBaseURL, fileName];
	
    NSLog(@"[SYNC] downloadingFile : %@", downloadURL);
    
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

- (void) extractZipFile
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
 
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip] autorelease];
    [zippedFile goToFirstFileInZip];
    
    BOOL continueReading = YES;
    while (continueReading) {
        
        // Get file info
        FileInZipInfo *info = [zippedFile getCurrentFileInZipInfo];
        
        // Read data into buffer
        ZipReadStream *stream = [zippedFile readCurrentFileInZip];
        NSMutableData *data2 = [[NSMutableData alloc] initWithLength:info.length];
        [stream readDataWithBuffer:data2];
        
        // Save data to file
        NSString *writePath = [directoryPath stringByAppendingPathComponent:info.name];
        NSError *error = nil;
        [data2 writeToFile:writePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"Error unzipping file: %@", [error localizedDescription]);
        }
        
        // Cleanup
        [stream finishedReading];
        [data2 release];
        
        // Check if we should continue reading
        continueReading = [zippedFile goToNextFileInZip];
    }
    
    [zippedFile close];
}


- (void) applySyncing
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    // extract zip file.
    [self extractZipFile];
    
    // process every message
    for(int i=0; i < [fileList count]; i++)
    {
        
        NSString *localFileName = [[fileList objectAtIndex:i] valueForKey:@"name"];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, [[localFileName componentsSeparatedByString:@"/"] lastObject]];
        
        NSData *bonjourMessageData = [NSData dataWithContentsOfFile:filePath];
        if(bonjourMessageData)
        {
            NSDictionary *bonjourMessageDict = [NSPropertyListSerialization propertyListWithData:bonjourMessageData options:NSPropertyListImmutable format:nil error:nil];
            
            
            BonjourMessage *aMessage = [[[BonjourMessage alloc] init] autorelease];
            aMessage.guid = [bonjourMessageDict valueForKey:@"guid"];
            aMessage.messageType = [[bonjourMessageDict valueForKey:@"messageType"] intValue];
            aMessage.userData = [bonjourMessageDict valueForKey:@"userData"];
            
            BonjouClientDataHandler *dataHandler = [[[BonjouClientDataHandler alloc] init] autorelease];
            BonjourMessageHandler *handler = [dataHandler findMessageHandlerForMessage:aMessage];
            
            NSLog(@"Processing file[%d] %@ with handler %@", i, localFileName, NSStringFromClass([handler class]) );
            [handler handleMessage:aMessage];

        }
               
    }
    
    
    
    // remove sync view...
    [self setHidden:YES];
    appDelegate.state = previousState;
    
    [appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
}

- (void)dealloc {
    [fileList release];
    [directoryPath release];
    [fileName release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [imageView setImage:[UIImage imageNamed:@"SyncBG.jpg"]];
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
    [progressView setProgress:1.0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    directoryPath = [[NSString stringWithFormat:@"%@/%@", documentsDir, [[fileName componentsSeparatedByString:@"."] objectAtIndex:0] ] retain];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
    
    // create directory
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [downloadData writeToFile:filePath atomically:YES];
    
    [downloadData release];
    
    [self applySyncing];
}

@end
