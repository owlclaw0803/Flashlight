//
//  AppDelegate.h
//  Flashlight
//
//  Created by kangZhe on 1/16/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *storyboardname;
@property(nonatomic, readwrite) UINavigationController *navigationController;
@property (nonatomic) BOOL *flashon;

@end

