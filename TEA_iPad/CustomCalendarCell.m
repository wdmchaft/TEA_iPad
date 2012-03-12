//
//  CustomCalendarCell.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 09.03.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "CustomCalendarCell.h"

@implementation CustomCalendarCell

@synthesize infoButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        infoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-35, 0, 25, 25)];
        [infoButton setBackgroundColor:[UIColor clearColor]];
        [infoButton setImage:[UIImage imageNamed:@"InfoButton.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:infoButton];
//        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-40, self.frame.size.height)];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
