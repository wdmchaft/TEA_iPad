

//
//  Sync.m
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "SyncUploadiPadDataService.h"
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

@implementation SyncUploadiPadDataService

- (void) updateMessage:(NSString*) message
{
    [progressLabel setText:message];
}


- (void) compressDocuments
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileNameForZipFile = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileNameForZipFile];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate] autorelease];
    
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:nil];
    
    for(NSString *file in files)
    {
        NSString *filePathToBeCompressed = [NSString stringWithFormat:@"%@/%@", documentsDir, file];
        NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject];
        NSString *extension = [[fileName componentsSeparatedByString:@"."] lastObject];
        
        if([extension isEqualToString:@"zip"])
        {
            continue;
        }
        
        ZipWriteStream *stream = [zippedFile writeFileInZipWithName:fileName compressionLevel:ZipCompressionLevelBest];
        NSData *data = [NSData dataWithContentsOfFile:filePathToBeCompressed];
        [stream writeData:data];
        [stream finishedWriting];
    }
    
    [zippedFile close];    
}


- (void) uploadSyncFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    NSString *boundry = [LocalDatabase stringWithUUID];
    
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
    
    NSString *uploadURL = [NSString stringWithFormat: @"%@/synciPadUpload.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 

    
    // Setup the request:
    NSMutableURLRequest *uploadRequest = [[[NSMutableURLRequest alloc]
                                           initWithURL:[NSURL URLWithString:uploadURL]
                                           cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30 ] autorelease];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];

    [uploadRequest setHTTPBody:postData];

    totalBytes = [postData length];
    
    [progressLabel setText:@"Güncel veri yedekleniyor..."];
    
    uploadURLConnection = [[[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self] autorelease];

}

- (void) downloadiPadSyncFile
{
    
    
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    fileStream = [[NSOutputStream outputStreamToFileAtPath:filePath append:NO] retain];
    [fileStream open];
    
    NSString *syncURL = [NSString stringWithFormat: @"%@/synciPadDownloadFile.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 
    NSString *downloadURL = [NSString stringWithFormat: @"device_id=%@", [appDelegate getDeviceUniqueIdentifier]];
            
    NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:syncURL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
	downloadURLConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
}

- (void) extractZipFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    NSString *fileName = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
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
        NSString *writePath = [NSString stringWithFormat:@"%@/%@", documentsDir, info.name];
        NSError *error = nil;
        [data2 writeToFile:writePath options:NSDataWritingAtomic error:&error];
        
        if (error) 
        {
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
    
    [appDelegate.viewController refreshLibraryView];
    [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
}

- (void) requestForSync
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [self setHidden:NO];
    
    BOOL syncEnabled = [[ConfigurationManager getConfigurationValueForKey:@"SYNC_ENABLED"] boolValue];    
    NSString *syncURL = [NSString stringWithFormat: @"%@/synciPadCheckFile.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 
    
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
            
            NSString *result = [[[NSString alloc] initWithData:syncFileData encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"iPad file check result is %@", result);
            
            if(![[result substringToIndex:2] isEqualToString:@"ok"])
            {
                [self compressDocuments];
                [self uploadSyncFile];
            }
            else 
            {
                // Get user defaults for first run
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *notFirstRun = [defaults objectForKey:@"notFirstRun"];
                
                if(!notFirstRun) // That means it is running for the first time.
                {
                    // Download iPad backup file and when finished, extract zip file...
                    [self downloadiPadSyncFile];
                }
                else
                {
                    [self setHidden:YES];
                    [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
                }
                [defaults setObject:@"notFirstRun" forKey:@"notFirstRun"];
                [defaults synchronize];
                
            }
        
        }
        @catch (NSException *exception) 
        {
            NSLog(@"Exception :: %@",  [exception description]);
            [self setHidden:YES];
            [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
        }
    }
    else
    {
        [self setHidden:YES];
        [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
    }
    
    [tmpData release];
}



- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
    if(connection == uploadURLConnection)
    {
        float progressValue = (float) totalBytesWritten / (float) totalBytes;
        NSLog(@"progressValue %f" ,progressValue); 
        
        [self updateProgress:[NSNumber numberWithFloat:progressValue]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSLog(@"timout");
    [self setHidden:YES];
    [appDelegate performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
}



- (void) updateProgress:(NSNumber*) progressValue
{
    [progressView setProgress: [progressValue floatValue]];
}



- (void)dealloc {

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

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == downloadURLConnection)
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
        [progressView setProgress: 0.5];
    }

}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == downloadURLConnection)
    {
        [progressView setProgress:1.0];
        
        if (fileStream != nil) 
        {
            [fileStream close];
            [fileStream release];
            fileStream = nil;
        }
        
        [self extractZipFile];
        
    }
    
    [self setHidden:YES];
    
}

@end
