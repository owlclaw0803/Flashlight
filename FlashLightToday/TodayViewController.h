//
//  TodayViewController.h
//  FlashLightToday
//
//  Created by kangZhe on 2/9/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnPower;
@property (weak, nonatomic) IBOutlet UIButton *btnSOS;
@property (weak, nonatomic) IBOutlet UIButton *btnColor;
@property (weak, nonatomic) IBOutlet UIButton *btnCompass;
@property (weak, nonatomic) IBOutlet UILabel *lblPower;
@property (weak, nonatomic) IBOutlet UILabel *lblColor;
@property (weak, nonatomic) IBOutlet UILabel *lblSOS;
@property (weak, nonatomic) IBOutlet UILabel *lblCompass;
@property (weak, nonatomic) IBOutlet UILabel *lblAngle;

- (IBAction)onclickPower:(id)sender;
- (IBAction)onclickColorPage:(id)sender;
- (IBAction)onclickSOS:(id)sender;
- (IBAction)onclickCompassPage:(id)sender;
- (IBAction)onclickCompass:(id)sender;
-(void)openApp:(int)type;


@end
