//
//  DWSearchBar.m
//  TEA_iPad
//
//  Created by Oguz Demir on 24/2/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "DWSearchBar.h"

@implementation DWSearchBar

@synthesize target, selector;

- ( void ) initSearchBar
{
    [self setBackground:[UIImage imageNamed:@"SearchBG.png"]];

}

- (void) searchingForText:(NSString *)aText
{
    [target performSelector:selector withObject:aText];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initSearchBar];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSearchBar];
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 25, bounds.origin.y , bounds.size.width - 25, bounds.size.height);
}


- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 25, bounds.origin.y , bounds.size.width - 25, bounds.size.height);
}

- (CGRect) placeholderRectForBounds:(CGRect)bounds
{
    return CGRectMake(10, 0, 214, 24);
}


@end


@implementation DWSearchBarDelegate

- (void)searchText:(NSTimer*)theTimer

{
    [searchBar searchingForText:searchBar.text];
    
    [searchTimer invalidate];
    searchTimer = nil;
}


- (id)init {
    self = [super init];
    if (self) {
        searchTimer = nil;
    }
    return self;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    searchBar = (DWSearchBar*) textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [searchBar searchingForText:searchBar.text];
    
    [searchTimer invalidate];
    searchTimer = nil;
    
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [searchTimer invalidate];
    searchTimer = nil;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField.text length] >= 3)
    {
        if(searchTimer)
        {
            [searchTimer invalidate];
            searchTimer = nil;
        }
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(searchText:) userInfo:nil repeats:NO];
    }
    
    return YES;
}



@end
