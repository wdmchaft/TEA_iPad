//
//  DWClientDataHandler.h
//  BonjourServer
//
//  Created by Oguz Demir on 28/6/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BonjourMessageHandler, BonjourMessage;

/*
enum kDataGroups 
{
    kDataGroupDeviceInfo        = 0,
    kDataGroupContent           = 1,
    kDataGroupQuiz              = 2,
    kDataGroupSession           = 3,
    kDataGroupNotification      = 4
};

enum kDataGroupDeviceInfoTags 
{
    kDataGroupDeviceName        = 11,
    kDataGroupDeviceType        = 12,
    kDataGroupDeviceOwner       = 13,
    kDataGroupDeviceId          = 14
};

enum kDataGroupContentTags
{
    kDataGroupContentStarted    = 20,
    kDataGroupContentName       = 21,
    kDataGroupContentSize       = 22,
    kDataGroupContentPath       = 23,
    kDataGroupContentData       = 24,
    kDataGroupContentType       = 25,
    kDataGroupContentExtension  = 26,
    kDataGroupContentGuid       = 27,
    kDataGroupContentEnded      = 30
};


enum kDataGroupQuizTags 
{
    kDataGroupQuizType           = 31,
    kDataGroupQuizStarted        = 32,
    kDataGroupQuizReference      = 33,
    kDataGroupQuizQuizType       = 34,
    kDataGroupQuizExpType        = 35,
    kDataGroupQuizOptCount       = 36,
    kDataGroupQuizSolveTime      = 37,
    kDataGroupQuizAnswer         = 38,
    kDataGroupQuizAnswerTime     = 39,
    kDataGroupQuizEnded          = 40,
    kDataGroupQuizGuid           = 41
};

enum kDataGroupSessionTags 
{
    kDataGroupSessionName           = 51,
    kDataGroupSessionGuid           = 52,
    kDataGroupSessionTeacherName    = 53,
    kDataGroupSessionLectureName    = 54,
    kDataGroupSessionLectureGuid    = 55
};

enum kDataGroupNotificationTags 
{
    kDataGroupNotificationStart     = 60,
    kDataGroupNotificationMessage   = 61,
    kDataGroupNotificationCode      = 62,
    kDataGroupNotificationEnd       = 69
};

enum kDataTypesTags
{
    kDataTypeString             = 150,
    kDataTypeLong               = 151,
    kDataTypeNumeric            = 152,
    kDataTypeDateTime           = 153,
    kDataTypeBinary             = 154
};

enum kContentTypes
{
    kContentTypeImage           = 180,
    kContentTypeVideo           = 181,
    kContentTypeDocument        = 182
};
*/


enum kNotificationCodes
{
    kNotificationCodeAppInBg    = 190,
    kNotificationCodeAppInFg    = 191
};


@class BonjourClient;

@interface BonjouClientDataHandler : NSObject
{
    NSMutableData *_data;
    int readLength;
    BonjourClient *client;
    NSMutableDictionary *notificationAttributes;
    
    long contentType;
    
    
    
    NSMutableArray *bonjourMessageHandlers;
}

- (BonjourMessageHandler*) findMessageHandlerForMessage:(BonjourMessage*) aMessage;


- (void) handleData;

@property (nonatomic, retain) NSMutableData *_data;
@property (nonatomic, assign) BonjourClient *client;

@end
