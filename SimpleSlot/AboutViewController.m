//
//  AboutViewController.m
//  DirtySlot
//
//  Created by netsnake on 2015/08/02.
//  Copyright (c) 2015年 netsnake. All rights reserved.
//
#import "AboutViewController.h"
#import "AppDelegate.h"
#import "PropertyFile.h"

@interface AboutViewController ()
    @property (weak, nonatomic) IBOutlet UISlider *slotSpeedSlide;
    @property (weak, nonatomic) IBOutlet UISlider *slotScaleSlide;
    @property (weak, nonatomic) IBOutlet UISwitch *SoundPresenceSwitch;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *backImageSegments;
    @property (weak, nonatomic) IBOutlet UILabel *slotSpeedLabel;
    @property (weak, nonatomic) IBOutlet UILabel *SlotScaleLabel;
    @property (weak, nonatomic) IBOutlet UISwitch *dirtySlotSwitch;
    @property (weak, nonatomic) IBOutlet UIImageView *imageView;
    @property (weak, nonatomic) IBOutlet UILabel *dirtySlotLabel;
@end
static UIImage *imgBack[C_MAX_BACK];
static AppDelegate *appDelegate;

@implementation AboutViewController

// 初期処理
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // デリゲート参照
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    // 設定値を取得
    PropertyDef propertyDef;
    PropertyFile* propertyFile=[PropertyFile alloc];
    [propertyFile getPropertyDef :&propertyDef];
    
    self.slotSpeedSlide.value                   = propertyDef.SlotSpeed;
    self.slotScaleSlide.value                   = propertyDef.SlotScale;
    self.dirtySlotSwitch.on                     = propertyDef.DirtySlot;
    self.SoundPresenceSwitch.on                 = propertyDef.SoundPresence;
    self.backImageSegments.selectedSegmentIndex = propertyDef.BackImage;
    self.slotSpeedLabel.text                    = [NSString stringWithFormat:@"Slot speed : %1.2f",self.slotSpeedSlide.value];
    self.SlotScaleLabel.text                    = [NSString stringWithFormat:@"Slot scale : %0.2f",self.slotScaleSlide.value];
    
    imgBack[0] = [UIImage imageNamed:@"BackImg001.png"];
    imgBack[1] = [UIImage imageNamed:@"BackImg002.png"];
    imgBack[2] = [UIImage imageNamed:@"BackImg003.png"];
    imgBack[3] = [UIImage imageNamed:@"BackImg004.png"];

    if(self.backImageSegments.selectedSegmentIndex < C_MAX_BACK){
        self.imageView.image = nil;
        self.imageView.image = imgBack[(int)self.backImageSegments.selectedSegmentIndex];
    }
}

// セグメント変更イベント
- (IBAction)backImageSegmentsValueChange:(id)sender {
    self.imageView.image = nil;
    self.imageView.image = imgBack[(int)self.backImageSegments.selectedSegmentIndex];
}

// スロット表示倍率変更イベント
- (IBAction)slotScaleValueChange:(id)sender
{
    self.SlotScaleLabel.text = [NSString stringWithFormat:@"Slot scale : %0.2f",self.slotScaleSlide.value];
}

// スロットスピード変更イベント
- (IBAction)slotSpeedSlideValueChange:(id)sender
{
    self.slotSpeedLabel.textColor = [UIColor blackColor];
    self.slotSpeedLabel.text = [NSString stringWithFormat:@"Slot speed : %1.2f",self.slotSpeedSlide.value];
    
    if(C_DIRTY_SPEED > self.slotSpeedSlide.value){
        if(self.dirtySlotSwitch.on == YES){
            self.dirtySlotSwitch.on = NO;
            self.dirtySlotLabel.textColor = [UIColor redColor];
        }
    }
}

// ダーティースロット変更イベント
- (IBAction)dirtySlotSwitchValueChange:(id)sender {
    self.dirtySlotLabel.textColor = [UIColor blackColor];

    if(C_DIRTY_SPEED > self.slotSpeedSlide.value){
        self.slotSpeedSlide.value = C_DIRTY_SPEED;
        self.slotSpeedLabel.text = [NSString stringWithFormat:@"Slot speed : %1.2f",self.slotSpeedSlide.value];
        self.slotSpeedLabel.textColor = [UIColor redColor];
    }
}

// 戻るボタン押下
- (IBAction)backItemClick:(id)sender
{
    // 設定結果を登録
    PropertyDef propertyDef;
    PropertyFile* propertyFile=[PropertyFile alloc];
    
    propertyDef.SlotSpeed = self.slotSpeedSlide.value;
    propertyDef.SlotScale = self.slotScaleSlide.value;
    propertyDef.DirtySlot = self.dirtySlotSwitch.on;
    propertyDef.SoundPresence = self.SoundPresenceSwitch.on;
    propertyDef.BackImage = self.backImageSegments.selectedSegmentIndex;
    [propertyFile setPropertyDef :&propertyDef];
    
    // AboutView を閉じる
    [self dismissViewControllerAnimated:YES completion:^{}];
    // appDelegate method をコール
    [appDelegate callFromAboutViewController];
}

// 後処理
- (void)dealloc {
    NSLog(@"dealloc");
    self.imageView.image = nil;
}

// メモリー異常
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
