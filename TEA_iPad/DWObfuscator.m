//
//  DWObfuscator.m
//  TEA_iPad
//
//  Created by Oguz Demir on 20/2/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "DWObfuscator.h"

@implementation DWObfuscator

static DWObfuscator* sharedInstance;

+ (DWObfuscator*) sharedInstance
{
    if(!sharedInstance)
    {
        sharedInstance = [[DWObfuscator alloc] init];
    }
    return sharedInstance;
}


- (BOOL) fileTypeNeedsObfuscation:(NSString*) fileTypeExtension
{
    NSString *localFileTypeExtension = [fileTypeExtension lowercaseString];
    if([localFileTypeExtension isEqualToString:@"xml"] || 
       [localFileTypeExtension isEqualToString:@"sqlite"])
    {
        return NO;
    }
    return YES;
}

- (BOOL) obfuscateFile:(NSString *)filePath
{
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSData *filePrefixData = [fileData subdataWithRange:NSMakeRange(0, 2)];
    NSString *filePrefixString = [[[NSString alloc] initWithData:filePrefixData encoding:NSASCIIStringEncoding] autorelease];

    if ([filePrefixString isEqualToString:@"ob"] ) 
    {
        return NO;
    }
    else
    {
        NSMutableData *newFileData = [[NSMutableData alloc] init];
        int fileDataLength = [fileData length];
        int chunkSize = fileDataLength / 8;
        int remainingBytes = fileDataLength % 8;
        
        [newFileData appendData:[NSData dataWithBytes:"ob" length:2]]; // add prefix
        
        // Obfuscate bytes
        for(int i =0; i < 8; i+=2)
        {
            NSData *currentChunk = [fileData subdataWithRange:NSMakeRange(i * chunkSize, chunkSize)];
            NSData *nextChunk = [fileData subdataWithRange:NSMakeRange((i + 1) * chunkSize, chunkSize)];
            
            [newFileData appendData:nextChunk];
            [newFileData appendData:currentChunk];
        }
        
        NSData *remainingFileData = [fileData subdataWithRange:NSMakeRange(8 * chunkSize, remainingBytes)];
        [newFileData appendData:remainingFileData];
        
        // write file
        BOOL result = [newFileData writeToFile:filePath atomically:YES];
        
        return result;

    }
}

- (NSData*) readObfuscatedFile:(NSString *)filePath
{
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSData *filePrefixData = [fileData subdataWithRange:NSMakeRange(0, 2)];
    NSString *filePrefixString = [[[NSString alloc] initWithData:filePrefixData encoding:NSASCIIStringEncoding] autorelease];
    
    if (![filePrefixString isEqualToString:@"ob"] ) 
    {
        return fileData;
    }
    else
    {
        fileData = [fileData subdataWithRange:NSMakeRange(2, [fileData length] - 2)];
        NSMutableData *newFileData = [[NSMutableData alloc] init];
        int fileDataLength = [fileData length];
        int chunkSize = fileDataLength / 8;
        int remainingBytes = fileDataLength % 8;
        
        // Reverse obfuscated bytes
        for(int i =0; i < 8; i+=2)
        {
            NSData *currentChunk = [fileData subdataWithRange:NSMakeRange(i * chunkSize, chunkSize)];
            NSData *nextChunk = [fileData subdataWithRange:NSMakeRange((i + 1) * chunkSize, chunkSize)];
            
            [newFileData appendData:nextChunk];
            [newFileData appendData:currentChunk];
        }
        
        NSData *remainingFileData = [fileData subdataWithRange:NSMakeRange(8 * chunkSize, remainingBytes)];
        [newFileData appendData:remainingFileData];
        
        return [newFileData autorelease];
    }
    
}

- (BOOL) isObfuscated:(NSString *)filePath
{
    NSData *filePrefixData = [[NSData dataWithContentsOfFile:filePath] subdataWithRange:NSMakeRange(0, 2)];
    NSString *filePrefixString = [[[NSString alloc] initWithData:filePrefixData encoding:NSASCIIStringEncoding] autorelease];
    
    if ([filePrefixString isEqualToString:@"ob"] ) 
    {
        return YES;
    }
    
    return NO;
}

@end
