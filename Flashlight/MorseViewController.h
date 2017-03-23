//
//  MorseViewController.h
//  Flashlight
//
//  Created by kangZhe on 2/4/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MorseViewController : UIViewController<UITextFieldDelegate>
{
    BOOL isTransmit;
    NSMutableArray *morsecodelist;
    NSMutableArray *morsetextlist;
    NSDictionary *morsecodes;
    NSString *curText;
    int codes[300];
    int length;
    AVCaptureDevice *captureDeviceClass;
    
    int codecount;
    int codecounttemp;
    int finishedcode;
    int finishedtext;
    NSTimer *timer;
    BOOL relax;
    
    UIView *torchview;
    BOOL torchAvailiable;
    
    BOOL FlashIsOn;
    
    BOOL paused;
    AVAudioPlayer *player;
    BOOL isClosed;
}

@property (weak, nonatomic) IBOutlet UIView *m_txtview;
@property (weak, nonatomic) IBOutlet UIImageView *m_morseback;
@property (weak, nonatomic) IBOutlet UIView *m_txtMain;
@property (weak, nonatomic) IBOutlet UILabel *m_lblMorseCodetitle;
@property (weak, nonatomic) IBOutlet UIView *m_MorseCode;

@property (weak, nonatomic) IBOutlet UIView *m_btnsview;
@property (weak, nonatomic) IBOutlet UIButton *m_flashonoff;
@property (weak, nonatomic) IBOutlet UIButton *m_trasmit;
@property (weak, nonatomic) IBOutlet UIButton *m_close;
@property (weak, nonatomic) IBOutlet UITextField *m_inputtext;

- (IBAction)onclickClose:(id)sender;
- (IBAction)onclickTransmit:(id)sender;
- (IBAction)onclickflashon:(id)sender;

- (void) initInterface;
- (void)initMorseCode;
- (void)ClearMorseText;
- (void)AddMorseText:(NSString*)str;
- (void) FlashTorch;
- (void)ChangeTextImage:(int)index withGrey:(BOOL)bGrey;

-(void)PlaySound:(NSString*) soundname;

@end
