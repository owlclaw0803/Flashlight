//
//  ColorController.h
//  Flashlight
//
//  Created by kangZhe on 2/4/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *m_imgAdjust;
@property (weak, nonatomic) IBOutlet UIButton *m_btnclose;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDot;

- (IBAction)onclickClose:(id)sender;

- (void) changeDotPosition:(CGPoint) pt;
- (BOOL) isinRound:(CGPoint) pt;
-(void)changeBackgroundColor;

@end
