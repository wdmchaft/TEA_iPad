

//
//  Sync.m
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "Sync.h"
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
#import "DWDatabase.h"

@implementation Sync

- (void) updateMessage:(NSString*) message
{
    [progressLabel setText:message];
}

- (NSString*) getSystemMessages
{
    
    NSLog(@"start");
    NSString *sql = @"select guid||'_'||deleted as guid from system_messages";
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql returnSimpleArray:YES] ;
    
    NSString *returnValue = [[CJSONSerializer serializer] serializeArray:result];
    
    NSLog(@"end");
    return [NSString stringWithFormat:@"{'system_messages': %@ }", returnValue];
}

- (void) requestForSync
{
   
    [progressLabel setText:@"Yedekten veri yükleme işlemi başlatılıyor..."];
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    previousState = appDelegate.state;
    appDelegate.state = kAppStateSyncing;
    [self setHidden:NO];
    
    // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
    BOOL syncEnabled = [[ConfigurationManager getConfigurationValueForKey:@"SYNC_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
    
    NSString *syncURL = [NSString stringWithFormat: @"%@/syncV2.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:syncURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    NSData *tmpData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
       
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
                
                
                //*****************************************************************
                NSString *updateReceivedNotificationsTable = [NSString stringWithFormat:@"update receivedNotifications set is_read = 0 where student_device_id = '%@'", appDelegate.getDeviceUniqueIdentifier];
                [DWDatabase getResultFromURL:[NSURL URLWithString:[ConfigurationManager getConfigurationValueForKey:@"ProtocolRemoteURL"]] withSQL:updateReceivedNotificationsTable];
                //*****************************************************************
                           
            }
            
            NSString *systemMessges = [self getSystemMessages];
            
            NSString *downloadURL = [NSString stringWithFormat: @"system_messages=%@&device_id=%@&start_date_time=%@", systemMessges, [appDelegate getDeviceUniqueIdentifier], lastSyncTime];
            
            //NSLog(@"[SYNC] %@", downloadURL);
            
            //  downloadURL = [downloadURL stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
            
            NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
            
            NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:syncURL]]];
            
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
            [request setHTTPBody:postData];
            
            NSData *syncFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            NSString *result = [[[NSString alloc] initWithData:syncFileData encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"data is %@", result);
            
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
                
                [progressLabel setText:@"Yedek veri dosyası yükleniyor..."];
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
    
    [tmpData release];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    directoryPath = [[NSString stringWithFormat:@"%@/%@", documentsDir, [[fileName componentsSeparatedByString:@"."] objectAtIndex:0] ] retain];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
    
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
    }
    
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];

    fileStream = [[NSOutputStream outputStreamToFileAtPath:filePath append:NO] retain];
    
    [fileStream open];
    
    totalReceivedBytes = 0;
    
    
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
		//downloadData = [[NSMutableData data] retain];
	} 
}

- (void) updateProgress:(NSNumber*) progressValue
{
    [progressView setProgress: [progressValue floatValue]];
}

- (void) extractZipFile
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
    
    [self performSelectorInBackground:@selector(updateMessage:) withObject:@"Yedek veri arşiv dosyası açılıyor..."];
    [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat: 0.0]];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip] autorelease];
    float numberOfZippedFile = (float) [zippedFile numFilesInZip];
    
    [zippedFile goToFirstFileInZip];
    
    BOOL continueReading = YES;
    int counter=0;
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
        
        counter ++;
        
        [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat: (float) counter / numberOfZippedFile]];

    }
    [self updateProgress:[NSNumber numberWithFloat:100.0 ]];

    [zippedFile close];
    
    
}


+ (NSData *)generatePostDataForData:(NSData *)uploadData
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_documents.zip", [appDelegate getDeviceUniqueIdentifier]];
    
    // Generate the post header:
    NSString *post = [NSString stringWithCString:
                      "--AaB03x\r\nContent-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\nContent-Type: application/zip\r\nContent-Transfer-Encoding: binary\r\n\r\n"
                                        encoding:NSASCIIStringEncoding];
    post = [NSString stringWithFormat:post, fileName];
    
    NSLog(@"Post Data........ %@", post);
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
    // Add the image:
    [postData appendData: uploadData];
    
    // Add the closing boundry:
    [postData appendData: [@"\r\n--AaB03x--" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    // Return the post data:
    return postData;
}


+ (void)uploadFile :(NSData*) yourData
{
    
    NSLog(@"NSData----yourData---------%@", yourData);
    // Generate the postdata:
    NSData *postData = [Sync generatePostDataForData: yourData];
    
    NSLog(@"NSData----postData---------%@", postData);
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    
    NSString *uploadURL = [ConfigurationManager getConfigurationValueForKey:@"uploadURL"];
    
    // Setup the request:
    NSMutableURLRequest *uploadRequest = [[[NSMutableURLRequest alloc]
                                           initWithURL:[NSURL URLWithString:uploadURL]
                                           cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30 ] autorelease];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setValue:@"multipart/form-data; boundary=AaB03x" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setHTTPBody:postData];
    
    // Execute the reqest:
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self];
    if (conn)
    {
        // Connection succeeded (even if a 404 or other non-200 range was returned).
        
    }
    else
    {
        // Connection failed (cannot reach server).
    }
    
}


+ (void) compressDocuments
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_documents.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate] autorelease];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDir error:nil];
    
    for(NSString *directoryItemPath in files)
    {
        if([directoryItemPath isEqualToString:@"documents.zip"])
        {
            continue;
        }
        
        ZipWriteStream *stream = [zippedFile writeFileInZipWithName:directoryItemPath compressionLevel:ZipCompressionLevelBest];
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsDir, directoryItemPath]];
        [stream writeData:data];
        [stream finishedWriting];
    }
    
    [zippedFile close];
    
    [Sync uploadFile:[NSData dataWithContentsOfFile:filePath]];
}




- (void) updateQuizAnswers
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString *questionAnswersURL = [NSString stringWithFormat: @"%@/quizAnswers.jsp?device_id=%@", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"], [appDelegate getDeviceUniqueIdentifier]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:questionAnswersURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    NSData *quizAnswersData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:quizAnswersData error:nil];
    [quizAnswersData release];
    
    NSArray *quizAnswers = [dictionary objectForKey:@"answers"];
    
    
    [[LocalDatabase sharedInstance] executeQuery:@"update library set quizAnswer='-1'"];
    for(NSDictionary *answer in quizAnswers)
    {
        
        NSString *updateSql = [NSString stringWithFormat: @"update library set quizAnswer='%@' where session_guid='%@' and guid = '%@'", [answer valueForKey:@"answer"], [answer valueForKey:@"session_guid"], [answer valueForKey:@"question_context_guid"]];
        
        [[LocalDatabase sharedInstance] executeQuery:updateSql];
    }
    
}

- (void) applySyncing
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    // extract zip file.
    [self extractZipFile];
    
    
    [self performSelectorInBackground:@selector(updateMessage:) withObject:@"Yedek veri mesajları işleniyor..."];
    
    // process every message
    int totalCount = [fileList count];
    for(int i=0; i < totalCount; i++)
    {
        NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];
        NSString *localFileName = [[fileList objectAtIndex:i] valueForKey:@"name"];
        NSString *localFileSessionId = [[fileList objectAtIndex:i] valueForKey:@"sessionGuid"];
        
        
        
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, [[localFileName componentsSeparatedByString:@"/"] lastObject]];
            
            NSData *bonjourMessageData = [NSData dataWithContentsOfFile:filePath];
            if(bonjourMessageData)
            {
                NSDictionary *bonjourMessageDict = [NSPropertyListSerialization propertyListWithData:bonjourMessageData options:NSPropertyListImmutable format:nil error:nil];
                
                
                if (![[[fileList objectAtIndex:i] valueForKey:@"deleted"] intValue]) 
                {
                    BonjourMessage *aMessage = [[BonjourMessage alloc] init];
                    aMessage.guid = [bonjourMessageDict valueForKey:@"guid"];
                    aMessage.messageType = [[bonjourMessageDict valueForKey:@"messageType"] intValue];
                    aMessage.userData = [bonjourMessageDict valueForKey:@"userData"];
                    
                    BonjouClientDataHandler *dataHandler = [[BonjouClientDataHandler alloc] init];
                    BonjourMessageHandler *handler = [dataHandler findMessageHandlerForMessage:aMessage];
                    
                    //NSLog(@"Processing file[%d] %@ with handler %@", i, localFileName, NSStringFromClass([handler class]) );
                    
                    if(aMessage.messageType != kMessageTypePauseQuiz)
                    {
                        
                        if(aMessage.messageType != kMessageTypeSessionInfo)
                        {
                            // Check active session is same with the message's session. If they are not the same then change iPad's current session to message's sesssion.
                            if(![appDelegate.session.sessionGuid isEqualToString:localFileSessionId])
                            {
                                appDelegate.session.sessionGuid = localFileSessionId;
                            }
                        }
                        
                        [handler handleMessage:aMessage];
                    }
                    
                    
                    
                    NSString *messageInsert = [NSString stringWithFormat:@"insert into system_messages select '%@', '%@', '%d', 0", aMessage.guid, @"", aMessage.messageType];
                    
                    [[LocalDatabase sharedInstance] executeQuery:messageInsert];
                    
                    [dataHandler release];
                    [aMessage release];
                }
                else
                {
                    
                    NSString *deleteSQL;
                    
                    if ([[bonjourMessageDict valueForKey:@"messageType"] intValue ] == 3) {
                        deleteSQL = [NSString stringWithFormat:@"delete from library where guid = '%@'",  [bonjourMessageDict valueForKey:@"guid"]];
                    }
                    else{
                        deleteSQL = [NSString stringWithFormat:@"delete from library where guid = '%@'",  [[bonjourMessageDict objectForKey:@"userData"] valueForKey:@"guid"]];
                        
                    }
                    
                    [[LocalDatabase sharedInstance] executeQuery:deleteSQL];
                    
                    NSString *deleteSystemMessagesSQL = [NSString stringWithFormat:@"delete from system_messages where guid = '%@'", [bonjourMessageDict valueForKey:@"guid"]];
                    [[LocalDatabase sharedInstance] executeQuery:deleteSystemMessagesSQL];
                    
                    NSString *insertSystemMessagesSQL = [NSString stringWithFormat:@"insert into system_messages select '%@', '%@', '%d', 1", [bonjourMessageDict valueForKey:@"guid"], @"", [[bonjourMessageDict valueForKey:@"messageType"]intValue]];
                    
                    [[LocalDatabase sharedInstance] executeQuery:insertSystemMessagesSQL];
                }
                
               
                
                //NSString *progressMessage = [NSString stringWithFormat:@"[%d / %d]", i, totalCount];
               // [self performSelectorInBackground:@selector(updateMessage:) withObject:progressMessage];
            }
       
        [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:(float) i / (float) totalCount]];

        [arPool release];
    }
    
    
    
    // remove sync view...
    [self setHidden:YES];
    appDelegate.state = previousState;
 
    [self updateQuizAnswers]; // Load quiz answers from database and update library.

    [appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
    
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
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
        
        progressLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 510, 1024, 25)] autorelease];
        [progressLabel setTextColor:[UIColor whiteColor]];
        [progressLabel setBackgroundColor:[UIColor clearColor]];
        [progressLabel setTextAlignment:UITextAlignmentCenter];
        [progressLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        
        [self addSubview:progressLabel]; 
        
        
    }
    return self;
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
  //  [downloadData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
        
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) 
        {
            break;
        } 
        else 
        {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
    
    totalReceivedBytes += dataLength;
    
 //   [downloadData appendData:data];
    [progressView setProgress: (float) totalReceivedBytes / (float) fileSize];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [progressView setProgress:1.0];
    
   /* NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    directoryPath = [[NSString stringWithFormat:@"%@/%@", documentsDir, [[fileName componentsSeparatedByString:@"."] objectAtIndex:0] ] retain];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
  */  
    // create directory
  //  [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
   // [downloadData writeToFile:filePath atomically:YES];
    
   // [downloadData release];
    
    if (fileStream != nil) 
    {
        [fileStream close];
        [fileStream release];
        fileStream = nil;
    }
    
    [self applySyncing];
}

@end
