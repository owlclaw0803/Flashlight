//
//  TodayViewController.m
//  FlashLightToday
//
//  Created by kangZhe on 2/9/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <CoreLocation/CoreLocation.h>

@interface TodayViewController () <NCWidgetProviding, CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    int selection;
}
@property (weak, nonatomic) IBOutlet UIButton *m_imgcompass;
@property (weak, nonatomic) IBOutlet UIImageView *imgCompass;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    selection = -1;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.imgCompass setTransform:CGAffineTransformMakeRotation(0)];
}

-(void)initView
{
    CGSize sz = self.view.frame.size;
    CGRect rt;
    
    rt = self.btnPower.frame;
    rt.origin.x = sz.width/8-rt.size.width/2;
    self.btnPower.frame = rt;
    rt.origin.x += sz.width/4;
    self.btnColor.frame = rt;
    rt.origin.x += sz.width/4;
    self.btnSOS.frame = rt;
    rt.origin.x += sz.width/4;
    self.btnCompass.frame = rt;
    
    rt = self.lblPower.frame;
    rt.origin.x = sz.width/8-rt.size.width/2;
    self.lblPower.frame = rt;
    rt.origin.x += sz.width/4;
    self.lblColor.frame = rt;
    rt.origin.x += sz.width/4;
    self.lblSOS.frame = rt;
    rt.origin.x += sz.width/4;
    self.lblCompass.frame = rt;
    
    //self.btnPower.layer.cornerRadius = self.btnPower.frame.size.width/2;
    //self.btnPower.layer.masksToBounds = YES;
    //self.btnColor.layer.cornerRadius = self.btnColor.frame.size.width/2;
    //self.btnColor.layer.masksToBounds = YES;
    //self.btnSOS.layer.cornerRadius = self.btnSOS.frame.size.width/2;
    //self.btnSOS.layer.masksToBounds = YES;
    //self.btnCompass.layer.cornerRadius = self.btnCompass.frame.size.width/2;
    //self.btnCompass.layer.masksToBounds = YES;
}

-(void)openApp:(int)type
{
    NSURL *pjURL = [NSURL URLWithString:@"flashlighttodaywidget://"];
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.flashlight.torch"];
    [defaults setValue:[NSString stringWithFormat:@"%d", type] forKey:@"clicktype"];
    [defaults synchronize];
    [self.extensionContext openURL:pjURL completionHandler:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    if(CGRectContainsPoint(self.btnPower.frame, pt)){
        selection = 0;
        [self.btnPower setImage:[UIImage imageNamed:@"WidgetColor_Flashlight_highlighted"] forState:UIControlStateNormal];
    }else if(CGRectContainsPoint(self.btnColor.frame, pt)){
        selection = 1;
        [self.btnColor setImage:[UIImage imageNamed:@"WidgetColor_Color_highlighted"] forState:UIControlStateNormal];
    }else if(CGRectContainsPoint(self.btnSOS.frame, pt)){
        selection = 2;
        [self.btnSOS setImage:[UIImage imageNamed:@"WidgetColor_SOS_highlighted"] forState:UIControlStateNormal];
    }else if(CGRectContainsPoint(self.btnCompass.frame, pt)){
        selection = 3;
        [self.btnCompass setImage:[UIImage imageNamed:@"WidgetColor_Compass_highlighted"] forState:UIControlStateNormal];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    if(!CGRectContainsPoint(self.btnPower.frame, pt) && selection == 0){
        selection = -1;
        [self.btnPower setImage:[UIImage imageNamed:@"WidgetColor_Flashlight"] forState:UIControlStateNormal];
    }else if(!CGRectContainsPoint(self.btnColor.frame, pt) && selection == 1){
        selection = -1;
        [self.btnColor setImage:[UIImage imageNamed:@"WidgetColor_Color"] forState:UIControlStateNormal];
    }else if(!CGRectContainsPoint(self.btnSOS.frame, pt) && selection == 2){
        selection = -1;
        [self.btnSOS setImage:[UIImage imageNamed:@"WidgetColor_SOS"] forState:UIControlStateNormal];
    }else if(!CGRectContainsPoint(self.btnCompass.frame, pt) && selection == 3){
        selection = -1;
        [self.btnCompass setImage:[UIImage imageNamed:@"WidgetColor_Compass"] forState:UIControlStateNormal];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    if(CGRectContainsPoint(self.btnPower.frame, pt) && selection == 0){
        [self.btnPower setImage:[UIImage imageNamed:@"WidgetColor_Flashlight"] forState:UIControlStateNormal];
        selection = -1;
        [self openApp:0];
    }else if(CGRectContainsPoint(self.btnColor.frame, pt) && selection == 1){
        [self.btnColor setImage:[UIImage imageNamed:@"WidgetColor_Color"] forState:UIControlStateNormal];
        selection = -1;
        [self openApp:1];
    }else if(CGRectContainsPoint(self.btnSOS.frame, pt) && selection == 2){
        selection = -1;
        [self.btnSOS setImage:[UIImage imageNamed:@"WidgetColor_SOS"] forState:UIControlStateNormal];
        [self openApp:2];
    }else if(CGRectContainsPoint(self.btnCompass.frame, pt) && selection == 3){
        selection = -1;
        [self.btnCompass setImage:[UIImage imageNamed:@"WidgetColor_Compass"] forState:UIControlStateNormal];
        [self openApp:3];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    CGSize size = self.preferredContentSize;
    size.height = 240;
    self.preferredContentSize = size;
    [self initView];
    
    [self.imgCompass setTransform:CGAffineTransformMakeRotation(0)];
    CGSize sz = self.view.frame.size;
    CGRect rt = self.imgCompass.frame;
    rt.origin.x = sz.width/2-rt.size.width/2;
    rt.size.width = 100;
    rt.size.height = 100;
    self.m_imgcompass.frame = rt;
    self.imgCompass.frame = rt;
    self.lblAngle.frame = CGRectMake(0, self.lblAngle.frame.origin.y, rt.origin.x - 20, self.lblAngle.frame.size.height);
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    self.imgCompass.transform = CGAffineTransformMakeRotation(-heading.magneticHeading * M_PI/180);

    int angle = (int)heading.magneticHeading;
    NSString *str;
    if(angle <= 22)
        str = @"N";
    else if(angle <= 66)
        str = @"NE";
    else if(angle <= 111)
        str = @"E";
    else if(angle <= 156)
        str = @"SE";
    else if(angle <= 202)
        str = @"S";
    else if(angle <= 246)
        str = @"SW";
    else if(angle <= 292)
        str = @"NW";
    else
        str = @"N";
    self.lblAngle.text = [NSString stringWithFormat:@"%d°%@", angle, str];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 5.0;
    margins.left = 1.0;
    return margins;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction)onclickPower:(id)sender {
    [self.btnPower setImage:[UIImage imageNamed:@"WidgetColor_Flashlight"] forState:UIControlStateNormal];
    [self openApp:0];
}

- (IBAction)onclickColorPage:(id)sender {
    [self.btnColor setImage:[UIImage imageNamed:@"WidgetColor_Color"] forState:UIControlStateNormal];
    [self openApp:1];
}

- (IBAction)onclickSOS:(id)sender {
    [self openApp:2];
}

- (IBAction)onclickCompassPage:(id)sender {
    [self openApp:3];
}

- (IBAction)onclickCompass:(id)sender {
    [self openApp:3];
}

@end
