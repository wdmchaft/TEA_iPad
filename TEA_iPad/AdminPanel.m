//
//  AdminPanel.m
//  TEA_iPad
//
//  Created by Oguz Demir on 24/4/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "AdminPanel.h"
#import "TEA_iPadAppDelegate.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "LocalDatabase.h"
#import "ConfigurationManager.h"

@interface AdminPanel ()

@end

@implementation AdminPanel
@synthesize sqlCommand;
@synthesize progressBar;
@synthesize popup;


- (void) compressAllDocuments
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileNameForZipFile = [NSString stringWithFormat:@"%@_file.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileNameForZipFile];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate] autorelease];

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:nil];
    
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
        [arPool release];
    }
    
    [zippedFile close];    
}


- (void) compressDBFile
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileNameForZipFile = [NSString stringWithFormat:@"%@_file.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileNameForZipFile];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate] autorelease];
    
    NSString *filePathToBeCompressed = [NSString stringWithFormat:@"%@/%@", documentsDir, @"library.sqlite"];
    NSString *fileName = [[@"library.sqlite" componentsSeparatedByString:@"/"] lastObject];
        
    ZipWriteStream *stream = [zippedFile writeFileInZipWithName:fileName compressionLevel:ZipCompressionLevelBest];
    NSData *data = [NSData dataWithContentsOfFile:filePathToBeCompressed];
    [stream writeData:data];
    [stream finishedWriting];

    [zippedFile close];    
}

- (void) uploadSyncFile
{

    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_file.zip", [appDelegate getDeviceUniqueIdentifier]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDir, fileName];
    
    int i=0;
    long totalSentBytes = 0;
    long lengthOfFile = [[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] valueForKey:@"NSFileSize"] longValue];
    
    NSLog(@"total file size %ldl", lengthOfFile);
    
    if(lengthOfFile > 10000000)
    {
        
        while (totalSentBytes < lengthOfFile) 
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            NSString *boundry = [LocalDatabase stringWithUUID];
            
            // Generate the post header:
            NSString *post = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"device_id\"\r\n\r\n%@\r\n", [appDelegate getDeviceUniqueIdentifier], [appDelegate getDeviceUniqueIdentifier]];
            
            NSString *newFileName = [NSString stringWithFormat:@"%@_file.zip- %d", [appDelegate getDeviceUniqueIdentifier], i];
            i++;
            
            post = [post stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\nContent-Type: application/zip\r\n\r\n", boundry, newFileName];
            
            //    post = [post stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"device_id\"\r\n\r\n%@", [appDelegate getDeviceUniqueIdentifier]];
            
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
            
            NSString *uploadURL = [NSString stringWithFormat: @"%@/adminFileUpload.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 
            
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
            
            [pool release];
        }
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"gönderim tamamlandı" message:@"gönderim tamamlandı" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
        
        [alertView show];
    }
    else 
    {
        
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
        
        NSString *uploadURL = [NSString stringWithFormat: @"%@/adminFileUpload.jsp", [ConfigurationManager getConfigurationValueForKey:@"SYNC_URL"]]; 
        
        
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
        
      //  [[[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self] autorelease];
        [NSURLConnection sendSynchronousRequest:uploadRequest returningResponse:nil error:nil];
        
        
        [postData release];
    }
    
}

- (void) updateProgress:(NSNumber*) progressValue
{
    [progressBar setProgress: [progressValue floatValue]];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
    float progressValue = (float) totalBytesWritten / (float)totalBytes; 
    [self updateProgress:[NSNumber numberWithFloat:progressValue]];
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [progressBar setProgress:1.0];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSqlCommand:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)reIndexDBClicked:(id)sender 
{
}

- (IBAction)uploadSQLFileClicked:(id)sender 
{
    [self compressDBFile];
    [self uploadSyncFile];
}

- (IBAction)uploadEntireDataClicked:(id)sender 
{
    [self compressAllDocuments];
    [self uploadSyncFile];
}

- (IBAction)runSQLCommandClicked:(id)sender {
}
- (void)dealloc {
    [popup release];
    [sqlCommand release];
    [progressBar release];
    [super dealloc];
}
- (IBAction)okClicked:(id)sender 
{
    [popup dismissPopoverAnimated:YES];
}

- (IBAction)cancelClicked:(id)sender {
    [popup dismissPopoverAnimated:YES];
}



@end
