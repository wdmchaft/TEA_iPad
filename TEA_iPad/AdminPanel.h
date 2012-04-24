//
//  AdminPanel.h
//  TEA_iPad
//
//  Created by Oguz Demir on 24/4/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdminPanel : UIViewController

{
    long totalBytes;
    long totalReceivedBytes;
    UIPopoverController *popup;
}

- (IBAction)reIndexDBClicked:(id)sender;
- (IBAction)uploadSQLFileClicked:(id)sender;
- (IBAction)uploadEntireDataClicked:(id)sender;
- (IBAction)runSQLCommandClicked:(id)sender;
- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *sqlCommand;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;
@property (retain, nonatomic) IBOutlet UIPopoverController *popup;


@end
