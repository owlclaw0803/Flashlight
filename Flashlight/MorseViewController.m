//
//  MorseViewController.m
//  Flashlight
//
//  Created by kangZhe on 2/4/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import "MorseViewController.h"
#import "AppDelegate.h"

#define MyAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface MorseViewController ()

@end

@implementation MorseViewController
@synthesize m_txtview, m_morseback, m_txtMain, m_lblMorseCodetitle, m_MorseCode;
@synthesize m_btnsview, m_flashonoff, m_trasmit, m_close;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initInterface];
    isTransmit = NO;
    timer = nil;
    morsecodelist = [[NSMutableArray alloc] init];
    morsetextlist = [[NSMutableArray alloc] init];
    captureDeviceClass = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    isClosed = NO;
    paused = NO;
    FlashIsOn = MyAppDelegate.flashon;
    if(FlashIsOn){
        [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_Off"] forState:UIControlStateNormal];
    }else{
        [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
    }
    torchAvailiable = NO;
    if(captureDeviceClass != nil){
        if ([captureDeviceClass hasTorch] && [captureDeviceClass hasFlash]){
            torchAvailiable = YES;
        }
    }
    
    torchview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [torchview setBackgroundColor:[UIColor whiteColor]];
    torchview.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TorchViewClick:)];
    gesture1.numberOfTapsRequired=1;
    [torchview addGestureRecognizer:gesture1];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"MorseCodes" ofType:@"plist"];
    morsecodes = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    curText = @"";
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [defaults objectForKey:@"MorseText"];
    for(int i = 0 ; i < str.length ; i++){
        NSRange range;
        range.length = 1;
        range.location = i;
        NSString *s = [str substringWithRange:range];
        [self AddMorseText:s];
    }
}

- (void)TorchViewClick:(UITapGestureRecognizer *)gesture
{
    [torchview removeFromSuperview];
    FlashIsOn = NO;
    [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
    if(isTransmit)
        [self onclickTransmit:nil];
}

- (void) initInterface
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGRect rt1 = m_txtview.frame;
    CGRect rt2 = m_btnsview.frame;
    rt1.origin.y -= size.height/2;
    rt2.origin.y += size.height/2;
    m_txtview.frame = rt1;
    m_btnsview.frame = rt2;
    
    rt1.origin.y += size.height/2;
    rt2.origin.y -= size.height/2;
    [self.m_inputtext becomeFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        m_txtview.frame = rt1;
        m_btnsview.frame = rt2;
    } completion:^(BOOL finished) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(string.length == 0 && range.location == curText.length-1 && range.length == 1)
        [self ClearMorseText];
    else
        [self AddMorseText:string];
    return YES;
}

-(void)ClearMorseText
{
    if(morsetextlist.count > 0){
        UIImageView *previous = (UIImageView*)[morsetextlist objectAtIndex:morsetextlist.count-1];
        [previous removeFromSuperview];
        [morsetextlist removeObjectAtIndex:morsetextlist.count-1];
        curText = [curText substringToIndex:curText.length-1];
        previous = nil;
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (IBAction)onclickClose:(id)sender {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGRect rt1 = m_txtview.frame;
    CGRect rt2 = m_btnsview.frame;
    rt1.origin.y -= size.height/2;
    rt2.origin.y += size.height/2;
    isClosed = YES;
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    [self changeTorch:NO];
    //[self.m_inputtext resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        m_txtview.frame = rt1;
        m_btnsview.frame = rt2;
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction)onclickTransmit:(id)sender
{
    CGRect rt2 = m_btnsview.frame;
    if(isTransmit){
        [self.m_inputtext becomeFirstResponder];
        rt2.origin.y -= 150;
        for(int i = 0 ; i < [morsetextlist count] ; i++){
            [self ChangeTextImage:i withGrey:NO];
        }
    }else{
        if(curText.length == 0)
            return;
        [self.m_inputtext resignFirstResponder];
        rt2.origin.y += 150;
        [self initMorseCode];
        for(int i = 0 ; i < [morsetextlist count] ; i++){
            [self ChangeTextImage:i withGrey:YES];
        }
    }
    paused = NO;
    [UIView animateWithDuration:0.4 animations:^{
        [m_btnsview setFrame:rt2];
        if(isTransmit)
           [m_morseback setImage:[UIImage imageNamed:@"Morse_Text_Mask"]];
        else
            [m_morseback setImage:[UIImage imageNamed:@"Morse_Text_Mask_After"]];
    } completion:^(BOOL finished) {
        if(isTransmit){
            [m_trasmit setImage:[UIImage imageNamed:@"Morse_Button_Transmit"] forState:UIControlStateNormal];
            [m_MorseCode setHidden:YES];
            [m_lblMorseCodetitle setHidden:YES];
            [timer invalidate];
            timer = nil;
            [self changeTorch:NO];
            [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
        }else{
            [m_trasmit setImage:[UIImage imageNamed:@"Morse_Button_Edit"] forState:UIControlStateNormal];
            [m_MorseCode setHidden:NO];
            [m_lblMorseCodetitle setHidden:NO];
            [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_Off"] forState:UIControlStateNormal];
            [self PlayMorseCode];
        }
        isTransmit = !isTransmit;
    }];
}

- (NSString*)getImageName:(NSString*)str withGreyImage:(BOOL)bgrey
{
    NSString *crop = @"";
    int chr = [str characterAtIndex:0];
    switch(chr){
        case '&':
            crop = @"and";
            break;
        case '@':
            crop = @"at";
            break;
        case ':':
            crop = @"colon";
            break;
        case ',':
            crop = @"comma";
            break;
        case '$':
            crop = @"dollar";
            break;
        case '.':
            crop = @"dot";
            break;
        case '=':
            crop = @"equal";
            break;
        case '!':
            crop = @"exclamation";
            break;
        case '(':
            crop = @"left_bracket";
            break;
        case '-':
            crop = @"minus";
            break;
        case '?':
            crop = @"question";
            break;
        case '"':
            crop = @"quote";
            break;
        case ')':
            crop = @"right_bracket";
            break;
        case ';':
            crop = @"semicolon";
            break;
        case '\'':
            crop = @"single_quote";
            break;
        case '/':
            crop = @"slash";
            break;
        case ' ':
            crop = @"space";
            break;
        case '_':
            crop = @"underline";
            break;
        default:
            crop = str;
            break;
    }
    if(bgrey)
        return [NSString stringWithFormat:@"Morse_Text_%@_gray",crop];
    return [NSString stringWithFormat:@"Morse_Text_%@",crop];
}

-(void)ChangeTextImage:(int)index withGrey:(BOOL)bGrey
{
    NSRange range;
    range.length = 1;
    range.location = index;
    NSString *str = [curText substringWithRange:range];
    str = [self getImageName:str withGreyImage:bGrey];
    UIImageView *view = [morsetextlist objectAtIndex:index];
    [view setImage:[UIImage imageNamed:str]];
}

-(void)AddMorseText:(NSString*)str
{
    CGSize sz = [m_txtMain frame].size;
    UIImage *img = [UIImage imageNamed:[self getImageName:str withGreyImage:NO]];
    UIImageView *imgview = [[UIImageView alloc] init];
    imgview.image = img;
    CGSize size = [img size];
    CGRect rt = CGRectMake(0, 0, size.width, size.height);
    if(morsetextlist.count > 0){
        UIImageView *previous = (UIImageView*)[morsetextlist objectAtIndex:morsetextlist.count-1];
        CGRect temp = previous.frame;
        rt.origin.x = temp.origin.x+temp.size.width;
        rt.origin.y = temp.origin.y;
        if(rt.origin.x + rt.size.width > sz.width){
            rt.origin.x = 0;
            if(rt.origin.y > 0)
                return;
            rt.origin.y += temp.size.height;
        }
    }
    curText = [NSString stringWithFormat:@"%@%@",curText, str];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:curText forKey:@"MorseText"];
    [defaults synchronize];
    imgview.frame = rt;
    [m_txtMain addSubview:imgview];
    [morsetextlist addObject:imgview];
}

- (void)initMorseCode
{
    [morsecodelist removeAllObjects];
    
    NSString *newstr = curText;
    for(int i = 0 ; i < [m_MorseCode subviews].count ; i++){
        UIView *v = [[m_MorseCode subviews] objectAtIndex:0];
        [v removeFromSuperview];
    }
    NSRange range;
    range.length = 1;
    length = 0;
    for(int i = 0 ; i < newstr.length ; i++){
        range.location = i;
        NSString *crop = [newstr substringWithRange:range];
        NSString *code = [morsecodes objectForKey:crop];
        NSRange range1;
        range1.length = 1;
        for(int j = 0 ; j < code.length ; j++){
            range1.location = j;
            NSString *c = [code substringWithRange:range1];
            if([c isEqualToString:@"0"])
                codes[length] = 0;
            else if([c isEqualToString:@"1"])
                codes[length] = 1;
            else
                codes[length] = 2;
            length++;
        }
        codes[length] = -1;
        length++;
    }
    
    UIImage *img1 = [UIImage imageNamed:@"morse_short_grey"];
    UIImage *img2 = [UIImage imageNamed:@"morse_long_grey"];
    UIImage *img3 = [UIImage imageNamed:@"morse_slash_grey"];
    CGSize size1 = [img1 size];
    CGSize size2 = [img2 size];
    CGSize size3 = [img3 size];
    CGRect rt = CGRectMake(0, 10, 0, size1.height/2);
    CGSize size = [m_MorseCode frame].size;
    for(int i = 0 ; i < length ; i++){
        if(codes[i] == -1){
            rt.origin.x += 10;
        }else{
            UIImageView* view = [[UIImageView alloc] init];
            switch(codes[i]){
                case 0:
                    rt.size.width = size1.width/2;
                    view.image = img1;
                    break;
                case 1:
                    rt.size.width = size2.width/2;
                    view.image = img2;
                    break;
                case 2:
                    rt.size.width = size3.width/2;
                    view.image = img3;
                    break;
            }
            if(rt.origin.x+rt.size.width > size.width){
                rt.origin.x = 0;
                rt.origin.y += rt.size.height+20;
            }
            view.frame = rt;
            rt.origin.x += rt.size.width;
            [m_MorseCode addSubview:view];
            [morsecodelist addObject:view];
        }
    }
}

- (void)PlayMorseCode
{
    codecount = 0;
    codecounttemp = 0;
    relax = NO;
    finishedcode = 0;
    finishedtext = 0;
    if(!torchAvailiable)
        [self.view addSubview:torchview];
    [self changeTorch:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(FlashTorch)
                                           userInfo:nil
                                            repeats:YES];
}

- (void) FlashTorch
{
    if(relax){
        [self changeTorch:YES];
        relax = NO;
        codecounttemp = 0;
        codecount++;
        finishedcode++;
        if(codes[codecount] == -1){
            codecount++;
            [self ChangeTextImage:finishedtext withGrey:NO];
            finishedtext++;
            if(finishedtext >= curText.length){
                [timer invalidate];
                timer = nil;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if(!isTransmit || isClosed)
                        return;
                    [self initMorseCode];
                    for(int i = 0 ; i < [morsetextlist count] ; i++){
                        [self ChangeTextImage:i withGrey:YES];
                    }
                    codecount = 0;
                    codecounttemp = 0;
                    relax = NO;
                    finishedcode = 0;
                    finishedtext = 0;
                    [self changeTorch:YES];
                    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                             target:self
                                                           selector:@selector(FlashTorch)
                                                           userInfo:nil
                                                            repeats:YES];
                });
            }
        }
    }else{
        if(codecounttemp == 0){
            if(codes[codecount] == 0)
                [self PlaySound:@"Di"];
            else if(codes[codecount] == 1)
                [self PlaySound:@"Da"];
        }
        if(codecounttemp < codes[codecount]*2){
            codecounttemp++;
        }else{
            [self changeTorch:NO];
            relax = YES;
            UIImageView* view = [morsecodelist objectAtIndex:finishedcode];
            if(codes[codecount] == 0)
                [view setImage:[UIImage imageNamed:@"morse_short"]];
            else if(codes[codecount] == 1)
                [view setImage:[UIImage imageNamed:@"morse_long"]];
            else if(codes[codecount] == 2)
                [view setImage:[UIImage imageNamed:@"morse_slash"]];
        }
    }
}

- (void)changeTorch:(BOOL)status
{
    if (torchAvailiable) {
        [captureDeviceClass lockForConfiguration:nil];
        if (status) {
            [captureDeviceClass setTorchMode:AVCaptureTorchModeOn];
            [captureDeviceClass setFlashMode:AVCaptureFlashModeOn];
        } else {
            [captureDeviceClass setTorchMode:AVCaptureTorchModeOff];
            [captureDeviceClass setFlashMode:AVCaptureFlashModeOff];
        }
        [captureDeviceClass unlockForConfiguration];
    }else{
        if(status)
            [torchview setBackgroundColor:[UIColor whiteColor]];
        else
            [torchview setBackgroundColor:[UIColor blackColor]];
    }
    FlashIsOn = status;
}

- (IBAction)onclickflashon:(id)sender {
    [self PlaySound:@"button_press"];
    if(!paused && timer != nil){
        [timer invalidate];
        timer = nil;
        FlashIsOn = NO;
        [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_Off"] forState:UIControlStateNormal];
        paused = YES;
    }else if(paused){
        FlashIsOn = YES;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(FlashTorch)
                                               userInfo:nil
                                                repeats:YES];
        [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
        paused = NO;
    }else{
        FlashIsOn = !FlashIsOn;
        if(FlashIsOn){
            [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_Off"] forState:UIControlStateNormal];
            [self.view addSubview:torchview];
        }else{
            [self.m_flashonoff setImage:[UIImage imageNamed:@"Map_Button_LED_On"] forState:UIControlStateNormal];
        }
        [self changeTorch:FlashIsOn];
    }
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
@end
