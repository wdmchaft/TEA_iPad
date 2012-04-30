

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
#import "GlobalSync.h"
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
@synthesize globalSync;


- (void) compressDocuments
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileNameForZipFile = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileNameForZipFile];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate] autorelease];
    
    [globalSync updateMessage:@"İlk yedek için içerikler arşivleniyor..."];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:nil];
    
    int counter = 0;
    
    for(NSString *file in files)
    {
        NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];
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
        
        CGFloat progressValue = (float)counter / (float)files.count / 2.0;
        [globalSync updateProgress:[NSNumber numberWithFloat:progressValue]];
        
        counter++;
        
        [arPool release];
        
    }
    
    [zippedFile close];    
}

- (void) mergeRemoteFiles:(int)fileCount
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    NSString *downloadURL = [NSString stringWithFormat: @"device_id=%@&file_count=%d", [appDelegate getDeviceUniqueIdentifier], fileCount];
    
    NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];

    NSString *syncURL = [NSString stringWithFormat: @"%@/synciPadMergeFiles.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 

    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:syncURL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
    [globalSync updateMessage:@"Sistem yedek dosyaları birleştiriliyor..."];
    
    NSData *syncFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *result = [[[NSString alloc] initWithData:syncFileData encoding:NSUTF8StringEncoding] autorelease];
    
    if(![result isEqualToString:@"ok"])
    {
        [globalSync updateMessage:@"Sistem yedek dosyaları birleştirilirken hata oluştu..."];
    }
    else 
    {
        [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
    }
}

- (void) uploadSyncFile
{
    
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    [globalSync updateMessage:@"İlk yedek veri arşiv dosyası sunucuya yedekleniyor..."]; 
    
    int i=0;
    long totalSentBytes = 0;
    long lengthOfFile = [[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] valueForKey:@"NSFileSize"] longValue];
    
    NSLog(@"total file size %ldl", lengthOfFile);
    

    while (totalSentBytes < lengthOfFile) 
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSString *boundry = [LocalDatabase stringWithUUID];
        
        // Generate the post header:
        NSString *post = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"device_id\"\r\n\r\n%@\r\n", [appDelegate getDeviceUniqueIdentifier], [appDelegate getDeviceUniqueIdentifier]];
        
        NSString *newFileName = [NSString stringWithFormat:@"%@_iPad.zip-%d", [appDelegate getDeviceUniqueIdentifier], i];
        i++;
        
        post = [post stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\nContent-Type: application/zip\r\n\r\n", boundry, newFileName];
                    
        // Get the post header int ASCII format:
        NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        // Generate the mutable data variable:
        NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
        [postData setData:postHeaderData];
        
        // Add the image:
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        [fileHandle seekToFileOffset:totalSentBytes];
        NSData *data = [fileHandle readDataOfLength:10000000];
        
        
        [postData appendData: data];
        
        
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
        
        [NSURLConnection sendSynchronousRequest:uploadRequest returningResponse:nil error:nil];
        
        [postData release];
        
        totalSentBytes += 10000000;
        
        NSLog(@"total send bytes size %ldl", totalSentBytes);
        
        float progressValue = 0.5 + ((float) totalSentBytes / (float) lengthOfFile / 2.0);
        [globalSync updateProgress:[NSNumber numberWithFloat:progressValue]];
        
        [pool release];
    }
        
    [self mergeRemoteFiles:i];
     
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
    
    [globalSync updateMessage:@"İlk yedek veri dosyası indiriliyor..."];    
	downloadURLConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
}

- (void) extractZipFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    NSString *fileName = [NSString stringWithFormat:@"%@_iPad.zip", [appDelegate getDeviceUniqueIdentifier]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    [globalSync updateMessage:@"İlk yedek veri arşiv dosyası açılıyor..."];   
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip] autorelease];
    float numberOfZippedFile = (float) [zippedFile numFilesInZip];
    
    [zippedFile goToFirstFileInZip];
    
    BOOL continueReading = YES;
    int counter=0;
    while (continueReading) {
        
        NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];
        
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
            [globalSync updateMessage:@"İlk yedek veri dosyası açılırken hata oluştu..."]; 
            NSLog(@"error is %@", [error localizedDescription]);
        }
        
        // Cleanup
        [stream finishedReading];
        [data2 release];
        
        // Check if we should continue reading
        continueReading = [zippedFile goToNextFileInZip];
        
        counter ++;
        
        CGFloat progressValue = 0.5 + ((float) counter / (float) numberOfZippedFile / 2.0);
        [globalSync updateProgress:[NSNumber numberWithFloat:progressValue]];

        
        [arPool release];
        
    }

    
    [zippedFile close];
    
    [globalSync updateMessage:@"İlk yedek veri arşiv dosyası açılma işlemi tamamlandı..."]; 
    
    [appDelegate.viewController refreshLibraryView];
    [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
}

- (void) requestForSync
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [globalSync updateMessage:@"İlk yedekleme işlemi başlatılıyor..."];
    
    BOOL syncEnabled = [[ConfigurationManager getConfigurationValueForKey:@"SYNC_ENABLED"] boolValue];    
    NSString *syncURL = [NSString stringWithFormat: @"%@/synciPadCheckFile.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 
    
    NSURLResponse *response = nil;
    NSError **error=nil; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:syncURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
    
    [globalSync updateMessage:@"İlk yedekleme servisi çağırılıyor..."];
    
    NSData *tmpData = [[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error]];
    
    [globalSync updateMessage:@"İlk yedekleme servisinden cevap alındı..."];
    
    BOOL syncCheck = syncEnabled && response;
    
#if !(HAS_FIRST_FILE_SYNC)
    syncCheck = false;
    NSLog(@"*********************************");
#endif  
    
    if(syncCheck)
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
            
            [globalSync updateMessage:@"Mevcut yedek dosyası kontrol ediliyor..."];
            
            NSData *syncFileData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            NSString *result = [[[NSString alloc] initWithData:syncFileData encoding:NSUTF8StringEncoding] autorelease];
            
            if(![[result substringToIndex:2] isEqualToString:@"ok"])
            {
                
                
                [globalSync updateMessage:@"Mevcut yedek dosyası bulunamadı, oluşturuluyor..."];
                
                [self compressDocuments];
                [self uploadSyncFile];
            }
            else 
            {
                sizeOfFile = [[result substringFromIndex:2] longLongValue];
                [globalSync updateMessage:@"Mevcut yedek dosyası bulundu..."];
                
                // Get user defaults for first run
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *notFirstRun = [defaults objectForKey:@"notFirstRun"];
                
                if(!notFirstRun) // That means it is running for the first time.
                {
                    [globalSync updateMessage:@"Uygulama ilk kez çalıştılıyor, yedek dosyası yüklenecek..."];
                    // Download iPad backup file and when finished, extract zip file...
                    [self downloadiPadSyncFile];
                }
                else
                {
                    [globalSync updateMessage:@"Uygulamanın yüklemesi gereken herhangi bir ilk yedek verisi yok..."];
                    [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
                }
                [defaults setObject:@"notFirstRun" forKey:@"notFirstRun"];
                [defaults synchronize];
                
            }
        
        }
        @catch (NSException *exception) 
        {
            [globalSync updateMessage:@"İlk yedek veri servis bağlantısında problem oluştu. Servisi kontrol ediniz..."];
            [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
        }
    }
    else
    {
        [globalSync updateMessage:@"İlk yedek veri senkronizasyonu 'disable' edilmiş..."];
        [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
    }
    
    [tmpData release];
}


/*
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
    if(connection == uploadURLConnection)
    {
        
        float progressValue = 0.5 + ((float) totalBytesWritten / (float) totalBytes / 2.0);
        [self updateProgress:[NSNumber numberWithFloat:progressValue]];
    }
}
 */

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSLog(@"timout");
    [appDelegate.viewController startSyncService:kSyncServiceTypeHomeworkSync];
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
        
        CGFloat progressValue = (float) totalReceivedBytes / (float) sizeOfFile / 2.0;
        [globalSync updateProgress:[NSNumber numberWithFloat:progressValue]];
    }

}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == downloadURLConnection)
    {
        [globalSync.progressView setProgress:1.0];
        
        if (fileStream != nil) 
        {
            [fileStream close];
            [fileStream release];
            fileStream = nil;
        }
        
        [self extractZipFile];
        
    }
    
    
    
}

@end
