//
//  ViewController.h
//  Flashlight
//
//  Created by kangZhe on 1/16/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define IMGCOUNT 22

@interface ViewController : UIViewController<UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{
    BOOL bFirst;
    int status;
    MKUserLocation *curLocation;
    
    int selected;
    BOOL bPowerOn;
    BOOL bFlashOn;
    UIImageView *imgview[IMGCOUNT*5];
    int brightnessangle;
    int TorchState;
    AVCaptureDevice *captureDeviceClass;
    NSTimer *timer;
    CLLocationManager *_locationManager;
    
    UIView *torchview;
    BOOL torchAvailiable;
    BOOL isGuideShowing;
    NSTimer *arctimer;
    int archighlight;
    int soscount;
    float scrollposition;
}

@property (weak, nonatomic) IBOutlet UIImageView *m_imgPower;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgPowerLight;
@property (weak, nonatomic) IBOutlet UIScrollView *m_headerscroll;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgColor;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgMorse;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgArc;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgArcHighlight;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgpoint;

@property (weak, nonatomic) IBOutlet UIButton *m_btnColor;
@property (weak, nonatomic) IBOutlet UIButton *m_btnround;
@property (weak, nonatomic) IBOutlet UIButton *m_btnPower;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgcompass;

- (BOOL) isInPowerButton:(CGPoint) pt;
- (BOOL) isInRoundButton:(CGPoint) pt;
- (void)changePosition:(CGPoint) from toPoint:(CGPoint) to;
- (int) isClickedOtherButton:(CGPoint) pt;
- (void) turnTorchOnOff;
- (void) initInterface;
- (void) changeTorchState:(int) state;
- (void) finishScrolling;
- (void) changeBrightness:(float)value;
- (void) FlashTorch;
-(void)ComeFromToday;
//Map
@property (weak, nonatomic) IBOutlet UIView *m_mapview;
@property (weak, nonatomic) IBOutlet MKMapView *m_map;
@property (weak, nonatomic) IBOutlet UIImageView *m_mapcompass;
@property (weak, nonatomic) IBOutlet UIButton *m_btnLocate;
@property (weak, nonatomic) IBOutlet UIButton *m_btnMapOn;
@property (weak, nonatomic) IBOutlet UIImageView *m_mapmaskback;

- (void)CompassGestureClicked:(UITapGestureRecognizer *)gesture;

- (IBAction)onclickMapLocation:(id)sender;
- (IBAction)onclickFlashOnOff:(id)sender;
- (IBAction)onclickClose:(id)sender;
- (void)TorchViewClick:(UITapGestureRecognizer *)gesture;


//Guide
@property (weak, nonatomic) IBOutlet UIView *guideview;
@property (weak, nonatomic) IBOutlet UIButton *btnguideok;
- (IBAction)onGuideClose:(id)sender;

@end

