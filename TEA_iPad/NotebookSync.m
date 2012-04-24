//
//  Sync.m
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "NotebookSync.h"
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
#import "LibraryView.h"

@implementation NotebookSync
@synthesize libraryView;

- (void) updateMessage:(NSString*) message
{
    [progressLabel setText:message];
}


- (NSString*) getNotebookFiles
{
    // Get all the notebook files.
    NSArray *notebooks = [[LocalDatabase sharedInstance] executeQuery:@"select * from notebookworkspace"];
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    // add notebook objects
    [jsonDictionary setValue:notebooks forKey:@"notebook_objects"];
    
    // Get user dictionary
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSMutableArray *notebookFiles = [[NSMutableArray alloc] init];
    
    // Generate notebook file objects
    NSArray *dirList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    
    for(NSDictionary *notebook in notebooks)
    {
        for(NSString *dirItem in dirList)
        {
            NSString *notebookGuid = [notebook valueForKey:@"notebook_guid"];
            
            if ([dirItem rangeOfString:notebookGuid].location != NSNotFound || [dirItem rangeOfString:@".jpg"].location != NSNotFound) 
            {
                NSMutableDictionary *fileDictionary = [[NSMutableDictionary alloc] init];
                [fileDictionary setValue:dirItem forKey:@"name"];
                
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsPath,dirItem ] error:nil];
                
                NSNumber *dirItemSize = [fileAttributes valueForKey: NSFileSize];
                NSDate *dirItemModDate = [fileAttributes valueForKey: NSFileModificationDate ];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd.MM.yyyy hh:mm:ss"];
                NSString *dirItemModDateString = [dateFormatter stringFromDate:dirItemModDate ];
                
                [fileDictionary setValue:dirItem forKey:@"fileName"];
                [fileDictionary setValue:dirItemSize forKey:@"fileSize"];
                [fileDictionary setValue:dirItemModDateString forKey:@"fileModDate"];
                
                [notebookFiles addObject:fileDictionary];
                
                [dateFormatter release];
                [fileDictionary release];
            }
        }
        
        
    }

    [jsonDictionary setValue:notebookFiles forKey:@"files"];
    
    NSString *returnValue = [[CJSONSerializer serializer] serializeDictionary:jsonDictionary];
    
    [notebookFiles release];
    [jsonDictionary release];
    
    return returnValue;
}


- (void) updateProgress:(NSNumber*) progressValue
{
    [progressView setProgress: [progressValue floatValue]];
}

- (void) downloadNotebookSyncFile
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


- (void) requestForNotebookSync
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];


    
    // Check notebook workspace. If there is no notebook in current workspace that means
    // application is recently installed. Full backup is required.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *restoreNotebooksRequired = [defaults objectForKey:@"restoreNotebooksRequired"];
    
    if(!restoreNotebooksRequired || [restoreNotebooksRequired isEqualToString:@"false"])

    {
        
        [defaults setObject:@"true" forKey:@"restoreNotebooksRequired"];
        [defaults synchronize];
        
        
        [self setHidden:NO];
        
        // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
        BOOL syncEnabled = [[ConfigurationManager getConfigurationValueForKey:@"SYNC_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
        
        NSString *syncURL = [NSString stringWithFormat: @"%@/syncNotebookDownload.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
        
        NSURLResponse *response = nil;
        NSError **error=nil; 
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:syncURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
        
        NSData *tmpData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    
        
        if(syncEnabled && response)
        {
            @try 
            {
                
                NSString *downloadURL = [NSString stringWithFormat: @"device_id=%@", [appDelegate getDeviceUniqueIdentifier]];
                
                NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                
                NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
                
                NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
                
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:syncURL]]];
                
                [request setHTTPMethod:@"POST"];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
                [request setHTTPBody:postData];
                
                NSData *syncFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                NSString *resultString = [[[NSString alloc] initWithData:syncFileData encoding:NSUTF8StringEncoding] autorelease]; NSLog(@"result is %@", resultString);
                
                NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:syncFileData error:nil];
                
                if(dictionary)
                {
                    fileName = [[dictionary valueForKey:@"fileName"] retain];
                    fileSize = [[dictionary valueForKey:@"size"] intValue];
                    
                    // Download file
                    [self downloadNotebookSyncFile];
                }
                else
                {
                    [self setHidden:YES];
                    [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
                }
                
                
                
            }
            @catch (NSException *exception) 
            {
                NSLog(@"Exception :: %@",  [exception description]);
                [self setHidden:YES];
                [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
            }
        }
        else
        {
            [self setHidden:YES];
            [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
        }
        
        [tmpData release];


    }
    else // Notebooks found, sync to server
    {
        
        [self setHidden:NO];
        
        // NSDictionary *iPadConfigDictionary = [ConfigurationManager getConfigurationValueForKey:@"iPadConfig"];
        BOOL syncEnabled = [[ConfigurationManager getConfigurationValueForKey:@"SYNC_ENABLED"] boolValue];// [[iPadConfigDictionary valueForKey:@"iPadSyncEnabled"] boolValue];
        
        NSString *syncURL = [NSString stringWithFormat: @"%@/syncNotebook.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; //[iPadConfigDictionary valueForKey:@"syncURL"];
        
        NSURLResponse *response = nil;
        NSError **error=nil; 
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:syncURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
        
        NSData *tmpData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
        
        
        if(syncEnabled && response)
        {
            @try 
            {
                
                NSString *notebookFiles = [self getNotebookFiles];
                NSString *downloadURL = [NSString stringWithFormat: @"notebooks=%@&device_id=%@", notebookFiles, [appDelegate getDeviceUniqueIdentifier]];
                
                
                NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                
                NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
                
                NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
                
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:syncURL]]];
                
                [request setHTTPMethod:@"POST"];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
                [request setHTTPBody:postData];
                
                NSData *syncFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                NSString *resultString = [[[NSString alloc] initWithData:syncFileData encoding:NSUTF8StringEncoding] autorelease]; NSLog(@"result is %@", resultString);
                
                NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:syncFileData error:nil];
                
                if(dictionary)
                {
                    fileList = [[dictionary valueForKey:@"files"] retain];
                    if(fileList && [fileList count] > 0)
                    {
                        [self compressDocuments];
                        [self uploadSyncFile];
                    }
                    
                    [self setHidden:YES];
                    [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
                }
                else
                {
                    [self setHidden:YES];
                    [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
                }
                
                
                
            }
            @catch (NSException *exception) 
            {
                NSLog(@"Exception :: %@",  [exception description]);
                [self setHidden:YES];
                [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
            }
        }
        else
        {
            [self setHidden:YES];
            [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
            
        }

        [tmpData release];
    }
       
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"timout");
    [self setHidden:YES];
}


- (void) compressDocuments
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_notebookSync.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate] autorelease];
    
    
    NSArray *files = fileList;
    
    for(NSDictionary *file in files)
    {
        NSString *directoryItemPath = [file valueForKey:@"fileName"];//  [NSString stringWithFormat:@"%@/%@", documentsDir, [file valueForKey:@"fileName"]];
        ZipWriteStream *stream = [zippedFile writeFileInZipWithName:directoryItemPath compressionLevel:ZipCompressionLevelBest];
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsDir, directoryItemPath]];
        [stream writeData:data];
        [stream finishedWriting];
    }
    
    [zippedFile close];
    
    //[Sync uploadFile:[NSData dataWithContentsOfFile:filePath]];
}

- (void) uploadSyncFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_notebookSync.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    NSString *boundry = [appDelegate getDeviceUniqueIdentifier];
    
    // Generate the post header:
    NSString *post = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"device_id\"\r\n\r\n%@\r\n", [appDelegate getDeviceUniqueIdentifier], [appDelegate getDeviceUniqueIdentifier]];
    post = [post stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\nContent-Type: application/zip\r\n\r\n", boundry, fileName];

//    post = [post stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"device_id\"\r\n\r\n%@", [appDelegate getDeviceUniqueIdentifier]];
    
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
    // Add the image:
    [postData appendData: [NSData dataWithContentsOfFile:filePath]];
    
    
    // Add the closing boundry:
    [postData appendData: [[NSString stringWithFormat:@"\r\n--%@--", boundry] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    
    NSString *uploadURL = [ConfigurationManager getConfigurationValueForKey:@"NOTEBOOK_SYNC_UPLOAD_URL"];
    
    // Setup the request:
    NSMutableURLRequest *uploadRequest = [[[NSMutableURLRequest alloc]
                                           initWithURL:[NSURL URLWithString:uploadURL]
                                           cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30 ] autorelease];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setHTTPBody:postData];
    
    // Execute the reqest:
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:uploadRequest delegate:nil];
    if (conn)
    {
        // Connection succeeded (even if a 404 or other non-200 range was returned).
        
    }
    else
    {
        // Connection failed (cannot reach server).
    }
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


- (void) extractZipFile
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
    
    [self performSelectorInBackground:@selector(updateMessage:) withObject:@"Notebook veri arşiv dosyası açılıyor..."];
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

- (void) applyNotebookSyncing
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    // extract zip file.
    [self extractZipFile];
    [self performSelectorInBackground:@selector(updateMessage:) withObject:@"Defter veri sayfaları işleniyor..."];
    
    
    // Insert notebooks into database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSData *workspaceData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsDir, @"workspace.json"]];
    
    NSArray *workspaces = [[CJSONDeserializer deserializer] deserialize:workspaceData error:nil];
    
    for(NSDictionary *workspace in workspaces)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into notebookworkspace (notebook_guid, notebook_type, notebook_name, state) values ('%@', '%@', '%@', '%@')",
                               [workspace valueForKey:@"notebook_guid"],
                               [workspace valueForKey:@"notebook_type"],
                               [workspace valueForKey:@"notebook_name"],
                               [workspace valueForKey:@"state"]];
        
        [[LocalDatabase sharedInstance] executeQuery:insertSQL];
    }
    
    [libraryView.notebookWorkspace loadWorkspace];
    
    // remove sync view...
    [self setHidden:YES];
    [appDelegate.viewController startSyncService:kSyncServiceTypeSync];
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
    directoryPath = [documentsDir retain];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
    
    // create directory
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [downloadData writeToFile:filePath atomically:YES];
    
    [downloadData release];
    
    [self applyNotebookSyncing];
    
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



@end
