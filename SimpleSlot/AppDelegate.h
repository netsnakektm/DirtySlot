//
//  AppDelegate.h
//  DirtySlot
//
//  Created by netsnake on 2015/08/02.
//  Copyright (c) 2015年 netsnake. All rights reserved.
//

#import <UIKit/UIKit.h>

// バックイメージの件数
#define C_MAX_BACK 4
// ダーティースロットのスピード
#define C_DIRTY_SPEED 10

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
    @property (strong, nonatomic) UIWindow *window;
    @property (retain, nonatomic) ViewController *mainViewController;
    -(void)callFromAboutViewController;
@end

