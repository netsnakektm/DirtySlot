//
//  PropertyFile.m
//  DirtySlot
//
//  Created by netsnake on 2015/08/02.
//  Copyright (c) 2015年 netsnake. All rights reserved.
//
#import "PropertyFile.h"

@implementation PropertyFile

// 設定値登録
- (void)setPropertyDef : (PropertyDef*)propertyDef
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setBool:    YES                         forKey:@"isSetted"];
    [ud setFloat:   propertyDef->SlotSpeed      forKey:@"SlotSpeed"];
    [ud setFloat:   propertyDef->SlotScale      forKey:@"SlotScale"];
    [ud setBool:    propertyDef->DirtySlot      forKey:@"DirtySlot"];
    [ud setBool:    propertyDef->SoundPresence  forKey:@"SoundPresence"];
    [ud setInteger: propertyDef->BackImage      forKey:@"BackImage"];
    [ud synchronize];
}

// 設定値取得
- (void)getPropertyDef : (PropertyDef*)propertyDef
{
    // NSUserDefaultsからデータを読み込む
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // 初期値設定済み
    if([ud boolForKey:@"isSetted"]){
        propertyDef->SlotSpeed      = [ud floatForKey   :@"SlotSpeed"];
        propertyDef->SlotScale      = [ud floatForKey   :@"SlotScale"];
        propertyDef->DirtySlot      = [ud boolForKey    :@"DirtySlot"];
        propertyDef->SoundPresence  = [ud boolForKey    :@"SoundPresence"];
        propertyDef->BackImage      = [ud integerForKey :@"BackImage"];
    }
    // デフォルトの初期値を設定
    else{
        propertyDef->SlotSpeed      = 6;     // 1〜10
        propertyDef->SlotScale      = 0.95;  // 0.5〜1.0
        propertyDef->DirtySlot      = NO;
        propertyDef->SoundPresence  = NO;
        propertyDef->BackImage      = 0;     // 0〜3
    }
}
@end

