//
//  BonjourDeviceInfoHandler.m
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "BonjourQuizAnswerHandler.h"
#import "LocalDatabase.h"
#import "LibraryView.h"
#import "TEA_iPadAppDelegate.h"

@implementation BonjourQuizAnswerHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeQuizAnswer;
    }
    return self;
}

- (void) updateQuizItem:(NSString*) guid withAnswer:(int) answer
{
    NSString *sql = [NSString stringWithFormat:@"update library set quizCorrectAnswer = '%d' where guid = '%@'", answer, guid];
    [[LocalDatabase sharedInstance] executeQuery:sql];
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    int answer =  [[aMessage.userData valueForKey:@"answer"] intValue];
    NSString *guid = [aMessage.userData valueForKey:@"guid"];
    
    
    NSString *sql = [NSString stringWithFormat:@"select * from library where guid = '%@'", guid];
    
    NSArray *libraryRows = [[LocalDatabase sharedInstance] executeQuery:sql];
    if(libraryRows && [libraryRows count] > 0)
    {
        {
            // get creation date
            if([aMessage.userData valueForKey:@"creationDate"])
            {
                sql = [NSString stringWithFormat:@"select * from library where guid = '%@'",  guid];
                NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql];

                if(result && [result count] == 1)
                {
                    int studentAnswerForQuestion = [[[result objectAtIndex:0] valueForKey:@"quizAnswer"] intValue];
                    int quizExpType = [[[result objectAtIndex:0] valueForKey:@"quizExpType"] intValue];
                    if(studentAnswerForQuestion == answer && quizExpType == 0) // delete if true
                    {
 
                        // Delete question preview and image
                        NSString *previewImage = [[result objectAtIndex:0] valueForKey:@"previewPath"];
                        NSString *quizImage = [[result objectAtIndex:0] valueForKey:@"quizImagePath"];

                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDir = [paths objectAtIndex:0];
                        
                        NSString *prevImagePath = [NSString stringWithFormat:@"%@/%@", documentsDir, previewImage];
                        NSString *quizImagePath = [NSString stringWithFormat:@"%@/%@", documentsDir, quizImage];

                        if(previewImage && [previewImage length] > 3)
                            [[NSFileManager defaultManager] removeItemAtPath:prevImagePath error:nil];
                        
                        if(quizImage && [quizImage length] > 3)
                            [[NSFileManager defaultManager] removeItemAtPath:quizImagePath error:nil];

                        // Delete record
                        sql = [NSString stringWithFormat:@"delete from library where guid = '%@'",  guid];
                        
                        [[LocalDatabase sharedInstance] executeQuery:sql];
                        
                    }
                    else 
                    {
                        [self updateQuizItem:guid withAnswer:answer];

                    }
                }
                else 
                {
                    [self updateQuizItem:guid withAnswer:answer];
                }
                
            }
            else 
            {
                [self updateQuizItem:guid withAnswer:answer];
            }
            
        }
    }
 
    [((LibraryView*) appDelegate.viewController) performSelectorOnMainThread:@selector(refreshDate:) withObject:[NSDate date] waitUntilDone:YES];
    
    [pool release];
}

@end
