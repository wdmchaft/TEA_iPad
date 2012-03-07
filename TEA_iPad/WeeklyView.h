//
//  ListView.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyView.h"


@class CalendarDataController, Calendar;

@interface WeeklyView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSMutableArray *dbResult;
    
    DailyView *selectedDailyView;
    
    CalendarDataController *controller;
    
    Calendar *calendar;
    
}

@property (nonatomic, assign) Calendar *calendar;

@property (nonatomic, assign) CalendarDataController *controller;

@property (nonatomic, assign) DailyView *selectedDailyView;

@property (nonatomic, retain) NSMutableArray *dbResult;
@property (nonatomic, retain) UITableView *tableView;

@end
