//
//  Library.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "Library.h"
#import "LibraryItem.h"
#import "LocalDatabase.h"

@implementation Library
static NSMutableArray* libraryItems;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

+ (void) initLibrary
{
   
}

+ (void) addLibraryItem:(LibraryItem*) pItem
{
    if(!libraryItems) {
        [self initLibrary];
    }
    [libraryItems addObject:pItem];
}

+ (void) deleteLibraryItem:(LibraryItem*) pItem
{
    if(!libraryItems) {
        [self initLibrary];
    }
    [libraryItems removeObject:pItem];
}

+ (void)dealloc
{
    [libraryItems release];
    [super dealloc];
}

@end
