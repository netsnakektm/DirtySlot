//
//  PropertyFile.h
//  DirtySlot
//
//  Created by netsnake on 2015/08/02.
//  Copyright (c) 2015年 netsnake. All rights reserved.
//
#import <Foundation/Foundation.h>

// 初期値格納形無構造体
typedef struct {
    bool      isSetted;  // データ有無判定
    float     SlotSpeed;
    float     SlotScale;
    bool      DirtySlot;
    bool      SoundPresence;
    NSInteger BackImage;
}PropertyDef;

@interface PropertyFile : NSObject
- (void)setPropertyDef : (PropertyDef*)propertyDef;
- (void)getPropertyDef : (PropertyDef*)propertyDef;
@end
