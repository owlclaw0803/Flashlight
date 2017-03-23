//
//  ViewController.m
//  Flashlight
//
//  Created by kangZhe on 1/16/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import "ViewController.h"
#import "ColorController.h"
#import "MorseViewController.h"
#import "AppDelegate.h"

#define MyAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define NONE_SELECTED -1
#define POWER_BUTTON 0
#define ROUND_BUTTON 1
#define COLOR_BUTTON 2
#define MORSE_BUTTON 3
#define ARC_BUTTON 4

#define DEFAULT_DELTA_LATITUDE		0.01
#define DETAULT_DELTA_LONGITUDE		0.01

@interface ViewController ()

@end

@implementation ViewController

@synthesize m_imgPower, m_imgPowerLight, m_imgColor, m_imgArc, m_imgMorse, m_imgArcHighlight, m_imgpoint, m_imgcompass;
@synthesize m_btnColor, m_btnPower, m_btnround;
@synthesize m_mapview, m_map, m_mapcompass;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selected = NONE_SELECTED;
    brightnessangle = 0;
    bFirst = YES;
    status = 0;
    
    m_map.delegate = self;
    captureDeviceClass = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    torchAvailiable = NO;
    if(captureDeviceClass != nil){
        if ([captureDeviceClass hasTorch] && [captureDeviceClass hasFlash]){
            torchAvailiable = YES;
        }
    }
    
    self.btnguideok.layer.cornerRadius = 4.0f;
    self.btnguideok.layer.masksToBounds = YES;
    [self.guideview setHidden:YES];
    isGuideShowing = NO;
    timer = nil;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    [m_mapview setHidden:YES];

    [_locationManager requestAlwaysAuthorization];
    
    torchview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [torchview setBackgroundColor:[UIColor whiteColor]];
    torchview.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TorchViewClick:)];
    gesture1.numberOfTapsRequired=1;
    [torchview addGestureRecognizer:gesture1];
    
    m_imgcompass.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CompassGestureClicked:)];
    gesture.numberOfTapsRequired=1;
    [m_imgcompass addGestureRecognizer:gesture];

    [self changeBrightness:0.6];
    [self initInterface];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)ComeFromToday
{
    NSUserDefaults *defaults1 = [[NSUserDefaults alloc]initWithSuiteName:@"group.flashlight.torch"];
    NSString *type = [defaults1 objectForKey:@"clicktype"];
    if(type != nil){
        [defaults1 removeObjectForKey:@"clicktype"];
        switch ([type intValue]) {
            case 0:
                break;
            case 1:
                [self gotoColorPage];
                break;
            case 2:
                [self runSOS];
                break;
            case 3:
                [m_mapview setHidden:NO];
                [m_map setShowsUserLocation:YES];
                [m_map setMapType:MKMapTypeStandard];
                status = 0;
                [_locationManager startUpdatingHeading];
                [m_mapcompass setHidden:NO];
                [self.m_btnLocate setImage:[UIImage imageNamed:@"Map_Button_Locating"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
}

-(void)runSOS
{
    CGSize screen = self.view.frame.size;
    CGSize sz = self.m_headerscroll.contentSize;
    float width = self.m_headerscroll.frame.size.height*38/153;
    CGRect visiblert = CGRectMake((sz.width-screen.width)/2-width*2, 0, screen.width, sz.height);
    [self.m_headerscroll scrollRectToVisible:visiblert animated:NO];
    TorchState = 10;
    [self turnTorchOnOff];
}

-(void)initTorch
{
    CGSize screen = self.view.frame.size;
    CGSize sz = self.m_headerscroll.contentSize;
    CGRect visiblert = CGRectMake((sz.width-screen.width)/2, 0, screen.width, sz.height);
    [self.m_headerscroll scrollRectToVisible:visiblert animated:NO];
    TorchState = 0;
    
}

- (void)CompassGestureClicked:(UITapGestureRecognizer *)gesture
{
    [m_mapview setHidden:NO];
    [m_map setShowsUserLocation:YES];
    [m_map setMapType:MKMapTypeStandard];
    status = 0;
    [_locationManager startUpdatingHeading];
    [m_mapcompass setHidden:NO];
    [self.m_btnLocate setImage:[UIImage imageNamed:@"Map_Button_Locating"] forState:UIControlStateNormal];
    if(bPowerOn){
        [self.m_btnMapOn setImage:[UIImage imageNamed:@"Map_Button_LED_Off"] forState:UIControlStateNormal];
    }else{
        [self.m_btnMapOn setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
    }
}

- (void)TorchViewClick:(UITapGestureRecognizer *)gesture
{
    [torchview removeFromSuperview];
    bPowerOn = NO;
    [self changeTorchState:TorchState];
}

- (IBAction)onclickMapLocation:(id)sender {
    if(status == 0){
        status = 1;
        [self.m_btnLocate setImage:[UIImage imageNamed:@"Map_Button_Locate"] forState:UIControlStateNormal];
        [_locationManager stopUpdatingHeading];
        [m_mapcompass setHidden:YES];
        [m_map setTransform:CGAffineTransformMakeRotation(0)];
    }else if(status == 1){
        status = 2;
        [self.m_btnLocate setImage:[UIImage imageNamed:@"Map_Button_Located"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.7 animations:^{
            MKCoordinateRegion defaultRegion = MKCoordinateRegionMake(curLocation.coordinate, MKCoordinateSpanMake(DEFAULT_DELTA_LATITUDE, DETAULT_DELTA_LONGITUDE));
            [m_map setRegion:defaultRegion];
        } completion:^(BOOL finished) {
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    }else if(status == 2){
        status = 0;
        [_locationManager startUpdatingHeading];
        [m_mapcompass setHidden:NO];
        [self.m_btnLocate setImage:[UIImage imageNamed:@"Map_Button_Locating"] forState:UIControlStateNormal];
    }
}

- (IBAction)onclickFlashOnOff:(id)sender {
    [self PlaySound:@"button_press"];
    if(!bPowerOn){
        [self.m_btnMapOn setImage:[UIImage imageNamed:@"Map_Button_LED_Off"] forState:UIControlStateNormal];
    }else{
        [self.m_btnMapOn setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
    }
    [self turnTorchOnOff];
}

-(void)PlaySound:(NSString*) soundname
{
    SystemSoundID completeSound;
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource: soundname withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(audioPath), &completeSound);
    AudioServicesPlaySystemSound (completeSound);
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:soundname ofType:@"wav"];
    
    //player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    //player.delegate = self;
    //player.numberOfLoops = 0;
    
    //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //[player play];
}

- (IBAction)onclickClose:(id)sender {
    [_locationManager startUpdatingHeading];
    [m_mapcompass setHidden:NO];
    [m_mapview setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    m_imgcompass.transform = CGAffineTransformMakeRotation(-heading.magneticHeading * M_PI/180);
    m_mapcompass.transform = CGAffineTransformMakeRotation(-heading.magneticHeading * M_PI/180);
    
    double rotation = heading.magneticHeading * 3.14159 / 180;
    CGPoint anchorPoint = CGPointMake(0, -23); // The anchor point for your pin
    
    [m_map setTransform:CGAffineTransformMakeRotation(-rotation)];
    
    [[m_map annotations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MKAnnotationView * view = [m_map viewForAnnotation:obj];
        
        [view setTransform:CGAffineTransformMakeRotation(rotation)];
        [view setCenterOffset:CGPointApplyAffineTransform(anchorPoint, CGAffineTransformMakeRotation(rotation))];
        
    }];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    curLocation = userLocation;
    if(bFirst == YES){
        [UIView animateWithDuration:0.4 animations:^{
            MKCoordinateRegion defaultRegion = MKCoordinateRegionMake(curLocation.coordinate, MKCoordinateSpanMake(DEFAULT_DELTA_LATITUDE, DETAULT_DELTA_LONGITUDE));
            [m_map setRegion:defaultRegion];
        } completion:^(BOOL finished) {
            [self.navigationController popViewControllerAnimated:NO];
        }];
        bFirst = NO;
    }
}

- (void) initInterface
{
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    
    [self.m_headerscroll setDecelerationRate:0.7];
    
    [m_imgArcHighlight setHidden:YES];
    
    CGRect rt = m_btnPower.frame;
    m_btnPower.layer.cornerRadius = rt.size.width/2;
    m_btnPower.layer.masksToBounds = YES;
    
    rt = m_btnround.frame;
    m_btnround.layer.cornerRadius = rt.size.width/2;
    m_btnround.layer.masksToBounds = YES;
    
    rt = m_btnColor.frame;
    m_btnColor.layer.cornerRadius = rt.size.width/2;
    m_btnColor.layer.masksToBounds = YES;
    //38*153
    rt = CGRectMake(0, 0, self.m_headerscroll.frame.size.height*38/153, self.m_headerscroll.frame.size.height);
    rt.origin.x = rt.size.width/2;
    for(int i = 0 ; i < IMGCOUNT*5 ; i++){
        imgview[i] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"original_%d",(i+11)%IMGCOUNT+1]]];
        [self.m_headerscroll addSubview:imgview[i]];
        [imgview[i] setFrame:rt];
        rt.origin.x += rt.size.width;
    }
    rt.origin.x -= rt.size.width/2;
    [self.m_headerscroll setContentSize:CGSizeMake(rt.origin.x, rt.size.height)];
    CGRect visiblert = CGRectMake((rt.origin.x-screen.width)/2, 0, screen.width, rt.size.height);
    [self.m_headerscroll scrollRectToVisible:visiblert animated:NO];
    
    scrollposition = (rt.size.width-screen.width)/2;
    int w = rt.origin.x/5;
    while(scrollposition >= w){
        scrollposition -= w;
    }
}

- (void) turnTorchOnOff{
    [self PlaySound:@"button_press"];
    if(!bPowerOn){
        bPowerOn = YES;
        if(torchAvailiable)
            [self changeBrightness:0.2+(brightnessangle+60)*0.8/120];
        else{
            [self.view addSubview:torchview];
            torchview.backgroundColor = [UIColor whiteColor];
        }
    }else{
        bPowerOn = NO;
    }
    [self changeTorchState:TorchState];
}

- (void) FlashTorch
{
    if(TorchState == 10){
        if(soscount < 6){
            if(soscount%2 == 0)
                bFlashOn = NO;
            else
                bFlashOn = YES;
        }else if(soscount < 18){
            if(soscount%4 == 2 || soscount%4 == 3)
                bFlashOn = NO;
            else
                bFlashOn = YES;
        }else if(soscount == 18){
            bFlashOn = NO;
        }
        if(bFlashOn){
            [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_On.png"]];
        }else
            [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_Off.png"]];
        soscount++;
        if(soscount > 18)
            soscount = 0;
    }else{
        if(!bFlashOn){
            bFlashOn = YES;
            [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_On.png"]];
        }else{
            bFlashOn = NO;
            [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_Off.png"]];
        }
    }
    if (torchAvailiable) {
            [captureDeviceClass lockForConfiguration:nil];
            if (bFlashOn) {
                [captureDeviceClass setTorchMode:AVCaptureTorchModeOn];
                [captureDeviceClass setFlashMode:AVCaptureFlashModeOn];
            } else {
                [captureDeviceClass setTorchMode:AVCaptureTorchModeOff];
                [captureDeviceClass setFlashMode:AVCaptureFlashModeOff];
            }
            [captureDeviceClass unlockForConfiguration];
    }else{
        if(bFlashOn)
            [torchview setBackgroundColor:[UIColor whiteColor]];
        else
            [torchview setBackgroundColor:[UIColor blackColor]];
    }
}

- (BOOL) isInPowerButton:(CGPoint) pt
{
    CGRect rt = m_btnPower.frame;
    float radius = rt.size.width/2;
    float ox = rt.origin.x + radius;
    float oy = rt.origin.y + radius;
    if(((ox-pt.x)*(ox-pt.x)+(oy-pt.y)*(oy-pt.y)) < radius*radius)
        return YES;
    return NO;
}

- (BOOL) isInRoundButton:(CGPoint) pt
{
    CGRect rt = m_btnround.frame;
    float radius = rt.size.width/2;
    float ox = rt.origin.x + radius;
    float oy = rt.origin.y + radius;
    if((((ox-pt.x)*(ox-pt.x)+(oy-pt.y)*(oy-pt.y)) < radius*radius) && ![self isInPowerButton:pt])
        return YES;
    return NO;
}

- (int) isClickedOtherButton:(CGPoint) pt
{
    if([self isInPowerButton:pt])
        return -1;
    if([self isInRoundButton:pt])
        return -1;
    
    CGRect rt = m_btnColor.frame;
    float radius = rt.size.width/2;
    float ox = rt.origin.x + radius;
    float oy = rt.origin.y + radius;
    if(((ox-pt.x)*(ox-pt.x)+(oy-pt.y)*(oy-pt.y)) > radius*radius)
        return -1;
    if(pt.y < oy)
        return -1;
    radius = sqrtf((float)((pt.x-ox)*(pt.x-ox)+(pt.y-oy)*(pt.y-oy)));
    float angle;
    if(pt.x == ox)
        angle = 180;
    else{
        angle = 2*asinf(sqrtf((float)((pt.x-ox)*(pt.x-ox)+(pt.y-oy+radius)*(pt.y-oy+radius)))*0.5/radius)*180/M_PI;
        if(pt.x < ox)
            angle = 360-angle;
    }
    
    if(angle < 160)
        return MORSE_BUTTON;
    if(angle > 200)
        return COLOR_BUTTON;
    return ARC_BUTTON;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(isGuideShowing)
        return;
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self.view];
    if([self isInPowerButton:touchLocation])
    {
        selected = POWER_BUTTON;
        [m_imgPower setImage:[UIImage imageNamed:@"button_down.png"]];
    }else if([self isInRoundButton:touchLocation]){
        selected = ROUND_BUTTON;
    }else{
        int result = [self isClickedOtherButton:touchLocation];
        if(result != -1)
            selected = result;
        switch(selected){
            case COLOR_BUTTON:
                [m_imgColor setImage:[UIImage imageNamed:@"color_clicked.png"]];
                break;
            case MORSE_BUTTON:
                [m_imgMorse setImage:[UIImage imageNamed:@"morse_clicked.png"]];
                break;
            case ARC_BUTTON:
                //[m_imgMorse setImage:[UIImage imageNamed:@"arc_rocket_highlight.png"]];
                break;
            default:
                break;
        }
    }
}

- (void)changePosition:(CGPoint) from toPoint:(CGPoint) to
{
    CGRect rt = m_btnround.frame;
    float radius = rt.size.width/2;
    float ox = rt.origin.x + radius;
    float oy = rt.origin.y + radius;
    
    float radius1 = sqrtf((float)((from.x-ox)*(from.x-ox)+(from.y-oy)*(from.y-oy)));
    float angle1;
    if(from.x == ox && from.y < oy)
        angle1 = 0;
    else if(from.x == ox)
        angle1 = 180;
    else{
        angle1 = 2*asinf(sqrtf((float)((from.x-ox)*(from.x-ox)+(from.y-oy+radius1)*(from.y-oy+radius1)))*0.5/radius1)*180/M_PI;
        if(from.x < ox)
            angle1 = 360-angle1;
    }
    
    float radius2 = sqrtf((float)((to.x-ox)*(to.x-ox)+(to.y-oy)*(to.y-oy)));
    float angle2;
    if(to.x == ox && to.y < oy)
        angle2 = 0;
    else if(to.x == ox)
        angle2 = 180;
    else{
        angle2 = 2*asinf(sqrtf((float)((to.x-ox)*(to.x-ox)+(to.y-oy+radius2)*(to.y-oy+radius2)))*0.5/radius2)*180/M_PI;
        if(to.x < ox)
            angle2 = 360-angle2;
    }
    brightnessangle = brightnessangle + angle2 - angle1;
    if(angle2 > 300 && angle1 < 60)
        brightnessangle -= 360;
    if(angle2 < 60 && angle1 > 300)
        brightnessangle += 360;
    if(brightnessangle < -60)
        brightnessangle = -60;
    if(brightnessangle > 60)
        brightnessangle = 60;
    
    CGRect rt1 = m_imgpoint.frame;
    float ox1 = rt1.origin.x + rt1.size.width/2;
    float oy1 = rt1.origin.y + rt1.size.height/2;
    float radius3 = sqrtf((float)((ox1-ox)*(ox1-ox)+(oy1-oy)*(oy1-oy)));
    rt1.origin.x = ox + sinf(brightnessangle*M_PI/180)*radius3-rt1.size.width/2;
    rt1.origin.y = oy - cosf(brightnessangle*M_PI/180)*radius3-rt1.size.height/2;
    m_imgpoint.frame = rt1;
    
    [self changeBrightness:0.2+(brightnessangle+60)*0.8/120];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self.view];
    CGPoint previous = [[touches anyObject] previousLocationInView:self.view];
    switch(selected){
        case POWER_BUTTON:
            if(![self isInPowerButton:touchLocation]){
                selected = NONE_SELECTED;
                [m_imgPower setImage:[UIImage imageNamed:@"button_up.png"]];
            }
            break;
        case ROUND_BUTTON:
            //if([self isInRoundButton:touchLocation])
                [self changePosition:previous toPoint:touchLocation];
            break;
        case COLOR_BUTTON:
            if([self isClickedOtherButton:touchLocation] != COLOR_BUTTON){
                selected = NONE_SELECTED;
                [m_imgColor setImage:[UIImage imageNamed:@"color.png"]];
            }
            break;
        case MORSE_BUTTON:
            if([self isClickedOtherButton:touchLocation] != MORSE_BUTTON){
                selected = NONE_SELECTED;
                [m_imgMorse setImage:[UIImage imageNamed:@"morse.png"]];
            }
            break;
        case ARC_BUTTON:
            if([self isClickedOtherButton:touchLocation] != ARC_BUTTON){
                selected = NONE_SELECTED;
                //[m_imgArc setImage:[UIImage imageNamed:@"arc_rocket.png"]];
            }
            break;
    }
    
    status = 1;
    [self.m_btnLocate setImage:[UIImage imageNamed:@"Map_Button_Locate"] forState:UIControlStateNormal];
    [_locationManager stopUpdatingHeading];
    [m_mapcompass setHidden:YES];
    [m_map setTransform:CGAffineTransformMakeRotation(0)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    switch(selected){
        case POWER_BUTTON:
            if([self isInPowerButton:touchLocation])
                [self turnTorchOnOff];
            [m_imgPower setImage:[UIImage imageNamed:@"button_up.png"]];
            break;
        case COLOR_BUTTON:
            if([self isClickedOtherButton:touchLocation] == COLOR_BUTTON){
                [self gotoColorPage];
            }
            [m_imgColor setImage:[UIImage imageNamed:@"color.png"]];
            break;
        case MORSE_BUTTON:
            if([self isClickedOtherButton:touchLocation] == MORSE_BUTTON){
                [self gotoMorsePage];
            }
            [m_imgMorse setImage:[UIImage imageNamed:@"morse.png"]];
            break;
        case ARC_BUTTON:
            if([self isClickedOtherButton:touchLocation] == ARC_BUTTON){
                [self showGuideView];
            }
            //[m_imgArc setImage:[UIImage imageNamed:@"arc_rocket.png"]];
            break;
    }
    selected = NONE_SELECTED;
}

-(void)showGuideView
{
    CGRect rt = m_imgArc.frame;
    self.guideview.frame = CGRectMake(self.view.frame.size.width/2,rt.origin.y+rt.size.height/2, 0, 0);
    [self.guideview setHidden:NO];
    isGuideShowing = YES;
    CGRect target = CGRectMake(50, 80, 220, 330);
    CGRect first = CGRectMake(110, 40, 100, 150);
    
    [UIView animateWithDuration:0.4 animations:^{
        self.guideview.frame = first;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.guideview.frame = target;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)hideGuideView
{
    CGRect rt = m_imgArc.frame;
    CGRect target = CGRectMake(50, 80, 220, 330);
    CGRect first = CGRectMake(110, 40, 100, 150);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.guideview.frame = first;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.guideview.frame = CGRectMake(self.view.frame.size.width/2,rt.origin.y+rt.size.height/2, 0, 0);
        } completion:^(BOOL finished) {
            [self.guideview setHidden:YES];
            isGuideShowing = NO;
            archighlight = 0;
            arctimer = [NSTimer scheduledTimerWithTimeInterval:0.4f
                                                     target:self
                                                   selector:@selector(ArcTimer)
                                                   userInfo:nil
                                                    repeats:YES];
        }];
    }];
}

-(void)ArcTimer
{
    if(archighlight%2 == 0){
        [m_imgArcHighlight setHidden:NO];
    }else{
        [m_imgArcHighlight setHidden:YES];
    }
    if(archighlight == 5){
        [arctimer invalidate];
        arctimer = nil;
    }
    archighlight++;
}

-(void)gotoColorPage
{
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    if(arctimer != nil){
        [arctimer invalidate];
        arctimer = nil;
    }
    UIStoryboard *storyBoard= [UIStoryboard storyboardWithName:MyAppDelegate.storyboardname bundle:nil];
    ColorController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"colorview"];
    [self.navigationController pushViewController:tab animated:NO];
}

-(void)gotoMorsePage
{
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    if(arctimer != nil){
        [arctimer invalidate];
        arctimer = nil;
    }
    [self initTorch];
    [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_Off.png"]];
    MyAppDelegate.flashon = bFlashOn;
    UIStoryboard *storyBoard= [UIStoryboard storyboardWithName:MyAppDelegate.storyboardname bundle:nil];
    MorseViewController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"morseview"];
    [self.navigationController pushViewController:tab animated:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float width = self.m_headerscroll.frame.size.height*38/153;
    CGPoint pt = self.m_headerscroll.contentOffset;
    
    CGSize size = scrollView.contentSize;
    int w = size.width/5;
    while(pt.x >= w){
        pt.x -= w;
    }
    if(pt.x - scrollposition > width || scrollposition - pt.x > width){
        [self PlaySound:@"cell_move"];
        scrollposition = pt.x;
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    CGPoint offset = [scrollView contentOffset];
    offset.x += screen.width/2;
    CGSize size = scrollView.contentSize;
    int width = size.width/5;
    if(offset.x >= 3*width || offset.x < 2*width){
        offset.x = (int)offset.x%width+ width*2;
    }
    offset.x -= screen.width/2;
    scrollView.contentOffset = offset;
    if(!decelerate)
        [self finishScrolling];
}

- (void) finishScrolling
{
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    float width = self.m_headerscroll.frame.size.height*38/153;
    CGPoint offset = [self.m_headerscroll contentOffset];
    offset.x += screen.width/2;
    CGSize size = self.m_headerscroll.contentSize;
    float gap = offset.x;
    while(gap >= width){
        gap -= width;
    }
    CGPoint offset1 = offset;
    offset1.x -= gap;
    if(gap > width/2)
        offset1.x += width;
    
    int w = size.width/5;
    float g = offset1.x;
    while(g >= w){
        g -= w;
    }
    float c = 5.5;
    while(g >= width){
        g -= width;
        c = c + 0.5;
        if(c > 10.5)
            c = 0;
    }
    if(c == 10.5){
        if(g < width/2){
            c = 0;
            offset1.x += width;
        }else{
            c = 9;
            offset1.x -= width;
        }
    }
    [self changeTorchState:c];
    
    offset1.x -= screen.width/2;
    [UIView animateWithDuration:0.3 animations:^{
        self.m_headerscroll.contentOffset = offset1;
    } completion:^(BOOL finished) {
    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self finishScrolling];
}

- (void) changeTorchState:(int) state
{
    TorchState = state;
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    if(!bPowerOn || state == 0){
        if (torchAvailiable) {
            [captureDeviceClass lockForConfiguration:nil];
            if (bPowerOn) {
                [captureDeviceClass setTorchMode:AVCaptureTorchModeOn];
                [captureDeviceClass setFlashMode:AVCaptureFlashModeOn];
            } else {
                [captureDeviceClass setTorchMode:AVCaptureTorchModeOff];
                [captureDeviceClass setFlashMode:AVCaptureFlashModeOff];
            }
            [captureDeviceClass unlockForConfiguration];
        }
        if(bPowerOn)
            [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_On.png"]];
        else
            [m_imgPowerLight setImage:[UIImage imageNamed:@"Indicator_Off.png"]];
        return;
    }
    soscount = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.5-0.12*state
                                             target:self
                                           selector:@selector(FlashTorch)
                                           userInfo:nil
                                            repeats:YES];
}

- (void) changeBrightness:(float)value
{
    if(bPowerOn && torchAvailiable){
        [captureDeviceClass lockForConfiguration:nil];
        [captureDeviceClass setTorchModeOnWithLevel:value error:NULL];
        [captureDeviceClass unlockForConfiguration];
    }
}

- (IBAction)onGuideClose:(id)sender {
    [self hideGuideView];
}
@end
