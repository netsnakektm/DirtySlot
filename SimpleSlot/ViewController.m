//
//  ViewController.m
//  DirtySlot
//
//  Created by netsnake on 2015/08/02.
//  Copyright (c) 2015年 netsnake. All rights reserved.
//
#import "ViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioServices.h>
#import "AboutViewController.h"
#import "PropertyFile.h"

// 定数(変更不可)
#define C_MAX_IMAGE       30
#define C_MAX_MEDAL        2
#define C_MAX_SLOT         3
#define C_MAX_JUGE        10
#define C_INDEX_777       20
// サウンド再生(変更不可)
#define C_STOP_SOUND      1052
#define C_START_SOUND_H   1036
#define C_START_SOUND_S   1027
#define C_SETTING_SOUND   1051
#define C_MEDAL_SOUND     1031
#define C_LOST_SOUND      1006
// サウンド切り替えスピード
#define C_SPEED_SOUND     5
// 待機中
#define C_WAIT            1
// プレイ中
#define C_PLAY            2
// ボタン非活性
#define C_DISABLE         3
// 判定後サウンドを再生するまでの待ち時間 0.25 × 1
#define C_WAIT_SOUND      1
// 判定画像OKが表示されるまでのタイムラグ 0.25 × 2
#define C_WAIT_JUGIMENT 2
// 判定画像OKが表示され時間 (0.25×15)-(0.25 × 4)
#define C_SHOW_JUGIMENT 14
// ハズレから再会までの待ち時間 0.25 × 2
#define C_WAIT_LOST_JUGIMENT 2

@interface ViewController ()
@end

// イメージ定義
static UIImage *imgSlotArray[C_MAX_IMAGE];
static UIImage *imgBack[C_MAX_BACK];
static UIImage *imgSlot;
static UIImage *imgManyMedal[C_MAX_MEDAL];

static UIImage *imgStop;
static UIImage *imgSetting;
static UIImage *imgStart;
static UIImage *imgStopDisabled;
static UIImage *imgSettingDisabled;
static UIImage *imgStartDisabled;

// イメージビュー
static UIImageView *slotView[C_MAX_SLOT][C_MAX_IMAGE];
static UIImageView *medalView[2];

// ボタン
static UIButton *stopButton1;
static UIButton *stopButton2;
static UIButton *stopButton3;
static UIButton *slotButton1;
static UIButton *slotButton2;
static UIButton *slotButton3;
static UIButton *settingButton;
static UIButton *startButton;

// ストップフラグ
static BOOL forceHitFlag0;
static BOOL forceHitFlag1;
static BOOL forceHitFlag2;

// タイマー
static NSTimer   *slotTimer[C_MAX_SLOT];
static NSTimer   *resultOkTimer;
static NSTimer   *resultNgTimer;
static NSInteger resultOkTimerCount;
static NSInteger resultNgTimerCount;

// 設定値格納
static PropertyDef propertyDef;

// スロット座標情報
static float rectSlot1A[4];
static float rectSlot1B[4];
static float rectSlot1C[4];
static float rectSlot2A[4];
static float rectSlot2B[4];
static float rectSlot2C[4];
static float rectSlot3A[4];
static float rectSlot3B[4];
static float rectSlot3C[4];

// スロットの添字
static int slotJugement[C_MAX_SLOT];
static int slotIndex0;
static int slotIndex1;
static int slotIndex2;

@implementation ViewController

// 初期設定
- (void)viewDidLoad {
    [super viewDidLoad];

    // デリゲート参照
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.mainViewController = self;
    
    // 画像ファイル／ボタン作成
    [self createInitial];

    // 画像／表示位置を設定する
    [self setInitial];

    // ボタン制御
    [self buttonEnabled:C_WAIT];

    // 初期スロット表示
    slotIndex0 = C_INDEX_777; // 7ぞろ目
    slotIndex1 = C_INDEX_777; // 7ぞろ目
    slotIndex2 = C_INDEX_777; // 7ぞろ目

    // スロット表示
    [self startAnimationZero];
    [self startAnimationOne];
    [self startAnimationTwo];
}

// ストップボタン0押下
- (void)stopButton0Click
{
    if(!stopButton1.enabled){
        return;
    }
    // スロット停止
    forceHitFlag0 = YES;
    // サウンドを再生する
    [self playSound:C_STOP_SOUND];
    // ストップボタン非活性
    [stopButton1 setEnabled:NO];
    [stopButton1 setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
}

// ストップボタン1押下
- (void)stopButton1Click
{
    if(!stopButton2.enabled){
        return;
    }
    // スロット停止
    forceHitFlag1 = YES;
    // サウンドを再生する
    [self playSound:C_STOP_SOUND];
    // ストップボタン非活性
    [stopButton2 setEnabled:NO];
    [stopButton2 setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
}

// ストップボタン2押下
- (void)stopButton2Click
{
    if(!stopButton3.enabled){
        return;
    }
    // スロット停止
    forceHitFlag2 = YES;
    // サウンドを再生する
    [self playSound:C_STOP_SOUND];
    // ストップボタン非活性
    [stopButton3 setEnabled:NO];
    [stopButton3 setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
}

// 設定ボタン押下
- (void)settingButtonClick
{
    // サウンドを再生する
    [self playSound:C_SETTING_SOUND];
    // ストーリーボードを指定する
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // 遷移先のViewControllerをStoryBoardをもとに作成
    AboutViewController *aboutViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"AboutView"];
    aboutViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // 画面をPUSHで遷移させる
    [self presentViewController:aboutViewController animated:YES completion:^ {}];
}

// 開始ボタン押下
- (void)startButtonClick
{
    // サウンドを再生する
    if(propertyDef.SlotSpeed > C_SPEED_SOUND){
        [self playSound:C_START_SOUND_H];
    }else{
        [self playSound:C_START_SOUND_S];
    }
    // ボタン制御
    [self buttonEnabled:C_PLAY];
    // スロット表示
    [self createSlotTimer];
}

// ボタン制御
- (void) buttonEnabled:(NSInteger) argValue
{
    if(C_WAIT == argValue){
        [startButton   setBackgroundImage:imgStart forState:UIControlStateNormal];
        [settingButton setBackgroundImage:imgSetting forState:UIControlStateNormal];
        [stopButton1   setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
        [stopButton2   setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
        [stopButton3   setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
        [stopButton1   setEnabled:NO];
        [stopButton2   setEnabled:NO];
        [stopButton3   setEnabled:NO];
        [settingButton setEnabled:YES];
        [startButton   setEnabled:YES];
    }else
    if(C_PLAY == argValue){
        [startButton   setBackgroundImage:imgStartDisabled forState:UIControlStateNormal];
        [settingButton setBackgroundImage:imgSettingDisabled forState:UIControlStateNormal];
        [stopButton1   setBackgroundImage:imgStop forState:UIControlStateNormal];
        [stopButton2   setBackgroundImage:imgStop forState:UIControlStateNormal];
        [stopButton3   setBackgroundImage:imgStop forState:UIControlStateNormal];
        [stopButton1   setEnabled:YES];
        [stopButton2   setEnabled:YES];
        [stopButton3   setEnabled:YES];
        [settingButton setEnabled:NO];
        [startButton   setEnabled:NO];
    }else
    if(C_DISABLE == argValue){
        [startButton   setBackgroundImage:imgStartDisabled forState:UIControlStateNormal];
        [settingButton setBackgroundImage:imgSettingDisabled forState:UIControlStateNormal];
        [stopButton1   setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
        [stopButton2   setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
        [stopButton3   setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
        [stopButton1   setEnabled:NO];
        [stopButton2   setEnabled:NO];
        [stopButton3   setEnabled:NO];
        [settingButton setEnabled:NO];
        [startButton   setEnabled:NO];
    }
}

// タイマー作成処理
-(void)createSlotTimer
{
    // ランダムな画像より回転を開始
    srand((unsigned)time(NULL));
    slotIndex0 = rand() % C_MAX_IMAGE;
    slotIndex1 = rand() % C_MAX_IMAGE;
    slotIndex2 = rand() % C_MAX_IMAGE;
    
    // タイマー解放
    for(int i=0; i < C_MAX_SLOT; i++){
        if(slotTimer[i] != nil){
            [slotTimer[i] invalidate];
            slotTimer[i] = nil;
            NSLog(@"slotTimer[%d] free.",i);
        }
    }

    forceHitFlag0 = NO;
    forceHitFlag1 = NO;
    forceHitFlag2 = NO;
    
    float timerSec = (11 - propertyDef.SlotSpeed) / 100;  // SlotSpeed 1〜10
    
    // タイマー作成処理
    slotTimer[0] = [NSTimer scheduledTimerWithTimeInterval:timerSec
                                                    target:self
                                                  selector:@selector(startAnimationZero)
                                                  userInfo:nil
                                                    repeats:YES];

    slotTimer[1] = [NSTimer scheduledTimerWithTimeInterval:timerSec
                                                    target:self
                                                  selector:@selector(startAnimationOne)
                                                  userInfo:nil
                                                   repeats:YES];
    

    slotTimer[2] = [NSTimer scheduledTimerWithTimeInterval:timerSec
                                                    target:self
                                                  selector:@selector(startAnimationTwo)
                                                  userInfo:nil
                                                   repeats:YES];
}

// スロット停止
- (void)stopAnimation:(NSInteger) indexValue
{
    if(slotTimer[indexValue] != nil){
        [slotTimer[indexValue] invalidate];
        slotTimer[indexValue] = nil;
        NSLog(@"slotTimer[%d] free.",(int)indexValue);
    }
}

// スロット停止調査
- (BOOL)isStopAnimation:(NSInteger) indexValue
{
    if(slotTimer[indexValue] == nil){
        return YES;
    }
    return NO;
}

// 判定
-(void)jugementSlot:(NSInteger) slotIndex VALUE:(NSInteger) hitIndex
{
    // ストップ位置の先頭画像添字を待避
    slotJugement[slotIndex] = (int)hitIndex-2;

    // スロットが全部停止状態
    if(forceHitFlag0
    && forceHitFlag1
    && forceHitFlag2){
        // サウンドを停止する
        if(propertyDef.SlotSpeed > C_SPEED_SOUND){
            [self stopSound:C_START_SOUND_H];
        }else{
            [self stopSound:C_START_SOUND_S];
        }

        // ボタンすべて非活性
        [self buttonEnabled:C_DISABLE];
        
        // 当たり処理
        if(slotJugement[0] == slotJugement[1] &&
           slotJugement[1] == slotJugement[2]){
            // OK処理
            [self jugementOkResult];
        }
        // ハズレ処理
        else{
            // NG処理
            [self jugementNgResult];
        }
    }
}

// スロット調整
- (int)ajustSlot:(int)argValue
{
    // ダーティースロットＯＮ＆＆スピード最速
    if(propertyDef.DirtySlot &&
       propertyDef.SlotSpeed >= C_DIRTY_SPEED){
           if(argValue == C_INDEX_777){
               return argValue;
           }
           return -1;
    }
    // ダーティースロットＯＦＦ||スピード遅い
    else{
        // 数字全表示の為微調整
        for(int i=0 ; i < C_MAX_JUGE; i++){
            if (argValue == 2+(C_MAX_SLOT*i)){
                return argValue;
            }
        }
        return -1;
    }
    return -1;
}

// スロット0表示
- (void)startAnimationZero
{
    int localIndex0 = slotIndex0;
    int ajustSlotReturn;
    
    if(forceHitFlag0){
        ajustSlotReturn = [self ajustSlot:localIndex0];
        if(ajustSlotReturn >= 0){
            localIndex0 = ajustSlotReturn;
            [self stopAnimation:0];
        }
    }
    // スロット0
    localIndex0++; if(localIndex0 >= C_MAX_IMAGE) localIndex0=0;
    CGRect slot1aRect = CGRectMake(rectSlot1A[0], rectSlot1A[1], rectSlot1A[2], rectSlot1A[3]);
    slotView[0][localIndex0].frame = slot1aRect;
    [self.view addSubview:slotView[0][localIndex0]];
    
    localIndex0++; if(localIndex0 >= C_MAX_IMAGE) localIndex0=0;
    CGRect slot1bRect = CGRectMake(rectSlot1B[0], rectSlot1B[1], rectSlot1B[2], rectSlot1B[3]);
    slotView[0][localIndex0].frame = slot1bRect;
    [self.view addSubview:slotView[0][localIndex0]];
    
    localIndex0++; if(localIndex0 >= C_MAX_IMAGE) localIndex0=0;
    CGRect slot1cRect = CGRectMake(rectSlot1C[0], rectSlot1C[1], rectSlot1C[2], rectSlot1C[3]);
    slotView[0][localIndex0].frame = slot1cRect;
    [self.view addSubview:slotView[0][localIndex0]];

    // スロットルが止まったら判定
    if ([self isStopAnimation:0]){
        [self jugementSlot:0 VALUE:localIndex0];
    }
    slotIndex0++; if(slotIndex0 >= C_MAX_IMAGE) slotIndex0=0;
}

// スロット1表示
- (void)startAnimationOne
{
    int localIndex1 = slotIndex1;
    int ajustSlotReturn;
    
    if(forceHitFlag1){
        ajustSlotReturn = [self ajustSlot:localIndex1];
        if(ajustSlotReturn >= 0){
            localIndex1 = ajustSlotReturn;
            [self stopAnimation:1];
        }
    }
    
    // スロット1
    localIndex1++; if(localIndex1 >= C_MAX_IMAGE) localIndex1=0;
    CGRect slot2aRect = CGRectMake(rectSlot2A[0], rectSlot2A[1], rectSlot2A[2], rectSlot2A[3]);
    slotView[1][localIndex1].frame = slot2aRect;
    [self.view addSubview:slotView[1][localIndex1]];
    
    localIndex1++; if(localIndex1 >= C_MAX_IMAGE) localIndex1=0;
    CGRect slot2bRect = CGRectMake(rectSlot2B[0], rectSlot2B[1], rectSlot2B[2], rectSlot2B[3]);
    slotView[1][localIndex1].frame = slot2bRect;
    [self.view addSubview:slotView[1][localIndex1]];
    
    localIndex1++; if(localIndex1 >= C_MAX_IMAGE) localIndex1=0;
    CGRect slot2cRect = CGRectMake(rectSlot2C[0], rectSlot2C[1], rectSlot2C[2], rectSlot2C[3]);
    slotView[1][localIndex1].frame = slot2cRect;
    [self.view addSubview:slotView[1][localIndex1]];
    
    // スロットルが止まったら判定
    if ([self isStopAnimation:1]){
        [self jugementSlot:1 VALUE:localIndex1];
    }
    slotIndex1++; if(slotIndex1 >= C_MAX_IMAGE) slotIndex1=0;
}

// スロット2表示
- (void)startAnimationTwo
{
    int localIndex2 = slotIndex2;
    int ajustSlotReturn;
    
    if(forceHitFlag2){
        ajustSlotReturn = [self ajustSlot:localIndex2];
        if(ajustSlotReturn >= 0){
            localIndex2 = ajustSlotReturn;
            [self stopAnimation:2];
        }
    }
    
    // スロット2
    localIndex2++; if(localIndex2 >= C_MAX_IMAGE) localIndex2=0;
    CGRect slot3aRect = CGRectMake(rectSlot3A[0], rectSlot3A[1], rectSlot3A[2], rectSlot3A[3]);
    slotView[2][localIndex2].frame = slot3aRect;
    [self.view addSubview:slotView[2][localIndex2]];
    
    localIndex2++; if(localIndex2 >= C_MAX_IMAGE) localIndex2=0;
    CGRect slot3bRect = CGRectMake(rectSlot3B[0], rectSlot3B[1], rectSlot3B[2], rectSlot3B[3]);
    slotView[2][localIndex2].frame = slot3bRect;
    [self.view addSubview:slotView[2][localIndex2]];
    
    localIndex2++; if(localIndex2 >= C_MAX_IMAGE) localIndex2=0;
    CGRect slot3cRect = CGRectMake(rectSlot3C[0], rectSlot3C[1], rectSlot3C[2], rectSlot3C[3]);
    slotView[2][localIndex2].frame = slot3cRect;
    [self.view addSubview:slotView[2][localIndex2]];
    
    // スロットルが止まったら判定
    if ([self isStopAnimation:2]){
        [self jugementSlot:2 VALUE:localIndex2];
    }
    slotIndex2++; if(slotIndex2 >= C_MAX_IMAGE) slotIndex2=0;
}

// 判定結果結果NS
- (void)jugementNgResult
{
    if(resultNgTimer != nil){
        [resultNgTimer invalidate];
        resultNgTimer = nil;
        NSLog(@"resultNgTimer free.");
    }

    resultNgTimerCount = 0;
    resultNgTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                   target:self
                                                 selector:@selector(jugementNgResultCallback)
                                                 userInfo:nil
                                                  repeats:YES];
}

// 判定結果NG コールバック
- (void)jugementNgResultCallback
{
    resultNgTimerCount++;
    
    if(resultNgTimerCount == C_WAIT_SOUND){
        // サウンドを再生する
        [self playSound:C_LOST_SOUND];
    }
    
    if(resultNgTimerCount == C_WAIT_LOST_JUGIMENT){
        if(resultNgTimer != nil){
            [resultNgTimer invalidate];
            resultNgTimer = nil;
            NSLog(@"resultNgTimer free.");
        }
        // ボタン制御
        [self buttonEnabled:C_WAIT];
    }
}

// 判定結果結果OK
- (void)jugementOkResult
{
    if(resultOkTimer != nil){
        [resultOkTimer invalidate];
        resultOkTimer = nil;
        NSLog(@"resultOkTimer free.");
    }

    resultOkTimerCount = 0;
    resultOkTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self
                                                selector:@selector(jugementOkResultCallback)
                                                userInfo:nil
                                                 repeats:YES];
}

// 判定結果OK コールバック
- (void)jugementOkResultCallback
{
    resultOkTimerCount++;

    if(resultOkTimerCount == C_WAIT_SOUND){
        // サウンドを再生する
        [self playSound:C_MEDAL_SOUND];
    }
    
    if(resultOkTimerCount == C_WAIT_JUGIMENT){
        // メダル画像表示
        NSInteger frameWidth  = self.view.frame.size.width;   // フレーム全体幅
        NSInteger frameHeight = self.view.frame.size.height;  // フレーム全体高さ
        // 表示比率
        float medalPaer = 0.75f;
        NSInteger imgWidth  = frameWidth  * medalPaer * propertyDef.SlotScale;
        NSInteger imgHeight = frameHeight * medalPaer * propertyDef.SlotScale;
        
        CGRect medalRect = CGRectMake((frameWidth/2) -(imgWidth/2),
                                      (frameHeight/2)-(imgHeight/2),
                                      imgWidth,
                                      imgHeight);
        // メダル画像表示
        srand((unsigned)time(NULL));
        int medalIndex = rand() % C_MAX_MEDAL;
        medalView[medalIndex].frame = medalRect;
        [self.view addSubview:medalView[medalIndex]];
    }

    if(resultOkTimerCount == C_SHOW_JUGIMENT){
        if(resultOkTimer != nil){
            [resultOkTimer invalidate];
            resultOkTimer = nil;
            NSLog(@"resultOkTimer free.");
        }
        // 画像／表示位置を設定する
        [self setInitial];
        // ボタン制御
        [self buttonEnabled:C_WAIT];
        // スロット表示
        slotIndex0--;
        slotIndex1--;
        slotIndex2--;
        [self startAnimationZero];
        [self startAnimationOne];
        [self startAnimationTwo];
    }
}

// 画像／表示位置を設定する
- (void)setInitial
{
    // 定数
    NSInteger C_ORIGINAL_WIDTH      = 490;  // オリジナル画像幅
    NSInteger C_ORIGINAL_HEIGHT     = 320;  // オリジナル画像高さ
    NSInteger C_ORIGINAL_SLOT1[4]   = {33 ,24,168,188}; // スロット１実座標
    NSInteger C_ORIGINAL_SLOT2[4]   = {175,24,314,188}; // スロット２実座標
    NSInteger C_ORIGINAL_SLOT3[4]   = {320,24,456,188}; // スロット３実座標
    NSInteger C_ORIGINAL_STOP1[4]   = {118,274,194,305}; // ストップボタン１実座標
    NSInteger C_ORIGINAL_STOP2[4]   = {201,274,288,305}; // ストップボタン２実座標
    NSInteger C_ORIGINAL_STOP3[4]   = {295,274,371,305}; // ストップボタン３実座標
    NSInteger C_ORIGINAL_SETTING[4] = { 86,233,146,252};  // セッティングボタン実座標
    NSInteger C_ORIGINAL_START[4]   = {345,234,404,252};  // スタートボタン実座標
    
    // 表示座標
    NSInteger slotImgHeight;
    NSInteger slotImgWidth;
    NSInteger slotImgX;
    NSInteger slotImgY;
    
    // スロット座標情報
    float scaleFit;
    float partHeigt;
    float rectStop1[4];
    float rectStop2[4];
    float rectStop3[4];
    float rectSetting[4];
    float rectStart[4];
    float rectSlotBtn1[4];
    float rectSlotBtn2[4];
    float rectSlotBtn3[4];
    
    // 変数初期化
    forceHitFlag0 = NO;
    forceHitFlag1 = NO;
    forceHitFlag2 = NO;
    
    // 設定値を取得
    PropertyFile* propertyFile=[PropertyFile alloc];
    [propertyFile getPropertyDef:&propertyDef];

    NSInteger frameWidth = self.view.frame.size.width;    // フレーム全体幅
    NSInteger frameHeight = self.view.frame.size.height;  // フレーム全体高さ

    // バックイメージ(画面全体)
    UIImageView *backImage = [[UIImageView alloc] initWithImage:imgBack[(int)propertyDef.BackImage]];
    CGRect backImageRect = CGRectMake(0,0, frameWidth, frameHeight);
    backImage.frame = backImageRect;
    [self.view addSubview:backImage];
 
    // スロットマシン表示
    // フレーム全体高さに宿所率に調整
    slotImgHeight = frameHeight * propertyDef.SlotScale;

    // 高さにたいする幅を算出(アスベスト比は変えない)
    slotImgWidth  = C_ORIGINAL_WIDTH * slotImgHeight / C_ORIGINAL_HEIGHT;

    // 開始Ｘ座標
    slotImgX = (frameWidth / 2) - (slotImgWidth / 2);

    // 開始Ｙ座標
    slotImgY = (frameHeight / 2) - (slotImgHeight / 2);

    // スロットマシン表示
    UIImageView *baclImage = [[UIImageView alloc] initWithImage:imgSlot];
    CGRect imgRect = CGRectMake(slotImgX, slotImgY, slotImgWidth, slotImgHeight);
    baclImage.frame = imgRect;
    [self.view addSubview:baclImage];

    // 規定値-スロット表示位置情報
    scaleFit  = (float)slotImgWidth/(float)C_ORIGINAL_WIDTH;
    partHeigt = ((float)C_ORIGINAL_SLOT1[3]-(float)C_ORIGINAL_SLOT1[1])/3 * scaleFit;
    
    // ストップボタン0表示位置算定→ボタン表示
    rectStop1[0] = slotImgX+(C_ORIGINAL_STOP1[0]*scaleFit);
    rectStop1[1] = slotImgY+(C_ORIGINAL_STOP1[1]*scaleFit);
    rectStop1[2] = (C_ORIGINAL_STOP1[2]-C_ORIGINAL_STOP1[0])*scaleFit;
    rectStop1[3] = (C_ORIGINAL_STOP1[3]-C_ORIGINAL_STOP1[1])*scaleFit;

    stopButton1.frame = CGRectMake(rectStop1[0], rectStop1[1], rectStop1[2], rectStop1[3]);
    [stopButton1 setBackgroundImage:imgStop forState:UIControlStateNormal];
    [stopButton1 addTarget:self action:@selector(stopButton0Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:stopButton1];
    
    // ストップボタン1表示位置算定→ボタン表示
    rectStop2[0] = slotImgX+(C_ORIGINAL_STOP2[0]*scaleFit);
    rectStop2[1] = slotImgY+(C_ORIGINAL_STOP2[1]*scaleFit);
    rectStop2[2] = (C_ORIGINAL_STOP2[2]-C_ORIGINAL_STOP2[0])*scaleFit;
    rectStop2[3] = (C_ORIGINAL_STOP2[3]-C_ORIGINAL_STOP2[1])*scaleFit;

    stopButton2.frame = CGRectMake(rectStop2[0], rectStop2[1], rectStop2[2], rectStop2[3]);
    [stopButton2 setBackgroundImage:imgStopDisabled forState:UIControlStateNormal];
    [stopButton2 addTarget:self action:@selector(stopButton1Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:stopButton2];
    
    // ストップボタン2表示位置算定→ボタン表示
    rectStop3[0] = slotImgX+(C_ORIGINAL_STOP3[0]*scaleFit);
    rectStop3[1] = slotImgY+(C_ORIGINAL_STOP3[1]*scaleFit);
    rectStop3[2] = (C_ORIGINAL_STOP3[2]-C_ORIGINAL_STOP3[0])*scaleFit;
    rectStop3[3] = (C_ORIGINAL_STOP3[3] - C_ORIGINAL_STOP3[1])*scaleFit;
    
    stopButton3.frame = CGRectMake(rectStop3[0], rectStop3[1], rectStop3[2], rectStop3[3]);
    [stopButton3 setBackgroundImage:imgStop forState:UIControlStateNormal];
    [stopButton3 addTarget:self action:@selector(stopButton2Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:stopButton3];

    // 設定ボタン表示位置算定→ボタン表示
    rectSetting[0] = slotImgX+(C_ORIGINAL_SETTING[0]*scaleFit);
    rectSetting[1] = slotImgY+(C_ORIGINAL_SETTING[1]*scaleFit);
    rectSetting[2] = (C_ORIGINAL_SETTING[2]-C_ORIGINAL_SETTING[0])*scaleFit;
    rectSetting[3] = (C_ORIGINAL_SETTING[3]-C_ORIGINAL_SETTING[1])*scaleFit;
    
    settingButton.frame = CGRectMake(rectSetting[0], rectSetting[1], rectSetting[2], rectSetting[3]);
    [settingButton setBackgroundImage:imgSetting forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingButtonClick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
    
    // スタートボタン表示位置算定→ボタン表示
    rectStart[0] = slotImgX+(C_ORIGINAL_START[0]*scaleFit);
    rectStart[1] = slotImgY+(C_ORIGINAL_START[1]*scaleFit);
    rectStart[2] = (C_ORIGINAL_START[2]-C_ORIGINAL_START[0])*scaleFit;
    rectStart[3] = (C_ORIGINAL_START[3]-C_ORIGINAL_START[1])*scaleFit;
    
    startButton.frame = CGRectMake(rectStart[0], rectStart[1], rectStart[2], rectStart[3]);
    [startButton setBackgroundImage:imgStart forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:startButton];
    
    // スロット１-ボタン(スロット画像で停止)
    rectSlotBtn1[0] = slotImgX+(C_ORIGINAL_SLOT1[0]*scaleFit);
    rectSlotBtn1[1] = slotImgY+(C_ORIGINAL_SLOT1[1]*scaleFit);
    rectSlotBtn1[2] = (C_ORIGINAL_SLOT1[2]-C_ORIGINAL_SLOT1[0])*scaleFit;
    rectSlotBtn1[3] = partHeigt * 3;
    
    slotButton1.frame = CGRectMake(rectSlotBtn1[0], rectSlotBtn1[1], rectSlotBtn1[2], rectSlotBtn1[3]);
    [slotButton1 addTarget:self action:@selector(stopButton0Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:slotButton1];
    
    // スロット２-ボタン(スロット画像で停止)
    rectSlotBtn2[0] = slotImgX+(C_ORIGINAL_SLOT2[0]*scaleFit);
    rectSlotBtn2[1] = slotImgY+(C_ORIGINAL_SLOT2[1]*scaleFit);
    rectSlotBtn2[2] = (C_ORIGINAL_SLOT2[2]-C_ORIGINAL_SLOT2[0])*scaleFit;
    rectSlotBtn2[3] = partHeigt * 3;

    slotButton2.frame = CGRectMake(rectSlotBtn2[0], rectSlotBtn2[1], rectSlotBtn2[2], rectSlotBtn2[3]);
    [slotButton2 addTarget:self action:@selector(stopButton1Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:slotButton2];
    
    // スロット３-ボタン(スロット画像で停止)
    rectSlotBtn3[0] = slotImgX+(C_ORIGINAL_SLOT3[0]*scaleFit);
    rectSlotBtn3[1] = slotImgY+(C_ORIGINAL_SLOT3[1]*scaleFit);
    rectSlotBtn3[2] = (C_ORIGINAL_SLOT3[2]-C_ORIGINAL_SLOT3[0])*scaleFit;
    rectSlotBtn3[3] = partHeigt * 3;
    
    slotButton3.frame = CGRectMake(rectSlotBtn3[0], rectSlotBtn3[1], rectSlotBtn3[2], rectSlotBtn3[3]);
    [slotButton3 addTarget:self action:@selector(stopButton2Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:slotButton3];

    // スロット１-スロット 表示位置算定
    rectSlot1A[0] = slotImgX+(C_ORIGINAL_SLOT1[0]*scaleFit);
    rectSlot1A[1] = slotImgY+(C_ORIGINAL_SLOT1[1]*scaleFit);
    rectSlot1A[2] = (C_ORIGINAL_SLOT1[2]-C_ORIGINAL_SLOT1[0])*scaleFit;
    rectSlot1A[3] = partHeigt;
    
    rectSlot1B[0] = slotImgX+(C_ORIGINAL_SLOT1[0]*scaleFit);
    rectSlot1B[1] = (slotImgY+(C_ORIGINAL_SLOT1[1]*scaleFit))+partHeigt;
    rectSlot1B[2] = (C_ORIGINAL_SLOT1[2]-C_ORIGINAL_SLOT1[0])*scaleFit;
    rectSlot1B[3] = partHeigt;
    
    rectSlot1C[0] = slotImgX+(C_ORIGINAL_SLOT1[0]*scaleFit);
    rectSlot1C[1] = (slotImgY+(C_ORIGINAL_SLOT1[1]*scaleFit)+(partHeigt*2));
    rectSlot1C[2] = (C_ORIGINAL_SLOT1[2]-C_ORIGINAL_SLOT1[0])*scaleFit;
    rectSlot1C[3] = partHeigt;
    
    // スロット２-スロット 表示位置算定
    rectSlot2A[0] = slotImgX+(C_ORIGINAL_SLOT2[0]*scaleFit);
    rectSlot2A[1] = slotImgY+(C_ORIGINAL_SLOT2[1]*scaleFit);
    rectSlot2A[2] = (C_ORIGINAL_SLOT2[2]-C_ORIGINAL_SLOT2[0])*scaleFit;
    rectSlot2A[3] = partHeigt;
    
    rectSlot2B[0] = slotImgX+(C_ORIGINAL_SLOT2[0]*scaleFit);
    rectSlot2B[1] = (slotImgY+(C_ORIGINAL_SLOT2[1]*scaleFit)+partHeigt);
    rectSlot2B[2] = (C_ORIGINAL_SLOT2[2]-C_ORIGINAL_SLOT2[0])*scaleFit;
    rectSlot2B[3] = partHeigt;
    
    rectSlot2C[0] = slotImgX+(C_ORIGINAL_SLOT2[0]*scaleFit);
    rectSlot2C[1] = (slotImgY+(C_ORIGINAL_SLOT2[1]*scaleFit)+(partHeigt*2));
    rectSlot2C[2] = (C_ORIGINAL_SLOT2[2]-C_ORIGINAL_SLOT2[0])*scaleFit;
    rectSlot2C[3] =  partHeigt;
    
    // スロット３-スロット 表示位置算定
    rectSlot3A[0] = slotImgX+(C_ORIGINAL_SLOT3[0]*scaleFit);
    rectSlot3A[1] = slotImgY+(C_ORIGINAL_SLOT3[1]*scaleFit);
    rectSlot3A[2] = (C_ORIGINAL_SLOT3[2]-C_ORIGINAL_SLOT3[0])*scaleFit;
    rectSlot3A[3] = partHeigt;
    
    rectSlot3B[0] = slotImgX+(C_ORIGINAL_SLOT3[0]*scaleFit);
    rectSlot3B[1] = slotImgY+(C_ORIGINAL_SLOT3[1]*scaleFit)+partHeigt;
    rectSlot3B[2] = (C_ORIGINAL_SLOT3[2]-C_ORIGINAL_SLOT3[0])*scaleFit;
    rectSlot3B[3] = partHeigt;
    
    rectSlot3C[0] = slotImgX+(C_ORIGINAL_SLOT3[0]*scaleFit);
    rectSlot3C[1] = (slotImgY+(C_ORIGINAL_SLOT3[1]*scaleFit)+(partHeigt*2));
    rectSlot3C[2] = (C_ORIGINAL_SLOT3[2]-C_ORIGINAL_SLOT3[0])*scaleFit;
    rectSlot3C[3] =  partHeigt;
}

// 画像ファイル／ボタン作成
- (void)createInitial
{
    imgBack[0]            = [UIImage imageNamed:@"BackImg001.png"];
    imgBack[1]            = [UIImage imageNamed:@"BackImg002.png"];
    imgBack[2]            = [UIImage imageNamed:@"BackImg003.png"];
    imgBack[3]            = [UIImage imageNamed:@"BackImg004.png"];
    imgSlot               = [UIImage imageNamed:@"SimpleSlot.png"];
    imgManyMedal[0]       = [UIImage imageNamed:@"ManylPochiko.png"];
    imgManyMedal[1]       = [UIImage imageNamed:@"ManyYen.png"];
    
    imgStop               = [UIImage imageNamed:@"StopButton.png"];
    imgSetting            = [UIImage imageNamed:@"SettingButton.png"];
    imgStart              = [UIImage imageNamed:@"StartButton.png"];
    imgStopDisabled       = [UIImage imageNamed:@"StopDisableButton.png"];
    imgSettingDisabled    = [UIImage imageNamed:@"SettingDisableButton.png"];
    imgStartDisabled      = [UIImage imageNamed:@"StartDisableButton.png"];
    
    imgSlotArray[0]       = [UIImage imageNamed:@"PIC00A.png"];
    imgSlotArray[1]       = [UIImage imageNamed:@"PIC00B.png"];
    imgSlotArray[2]       = [UIImage imageNamed:@"PIC00C.png"];
    imgSlotArray[3]       = [UIImage imageNamed:@"PIC01A.png"];
    imgSlotArray[4]       = [UIImage imageNamed:@"PIC01B.png"];
    imgSlotArray[5]       = [UIImage imageNamed:@"PIC01C.png"];
    imgSlotArray[6]       = [UIImage imageNamed:@"PIC02A.png"];
    imgSlotArray[7]       = [UIImage imageNamed:@"PIC02B.png"];
    imgSlotArray[8]       = [UIImage imageNamed:@"PIC02C.png"];
    imgSlotArray[9]       = [UIImage imageNamed:@"PIC03A.png"];
    imgSlotArray[10]      = [UIImage imageNamed:@"PIC03B.png"];
    imgSlotArray[11]      = [UIImage imageNamed:@"PIC03C.png"];
    imgSlotArray[12]      = [UIImage imageNamed:@"PIC04A.png"];
    imgSlotArray[13]      = [UIImage imageNamed:@"PIC04B.png"];
    imgSlotArray[14]      = [UIImage imageNamed:@"PIC04C.png"];
    imgSlotArray[15]      = [UIImage imageNamed:@"PIC05A.png"];
    imgSlotArray[16]      = [UIImage imageNamed:@"PIC05B.png"];
    imgSlotArray[17]      = [UIImage imageNamed:@"PIC05C.png"];
    imgSlotArray[18]      = [UIImage imageNamed:@"PIC06A.png"];
    imgSlotArray[19]      = [UIImage imageNamed:@"PIC06B.png"];
    imgSlotArray[20]      = [UIImage imageNamed:@"PIC06C.png"];
    imgSlotArray[21]      = [UIImage imageNamed:@"PIC07A.png"];
    imgSlotArray[22]      = [UIImage imageNamed:@"PIC07B.png"];
    imgSlotArray[23]      = [UIImage imageNamed:@"PIC07C.png"];
    imgSlotArray[24]      = [UIImage imageNamed:@"PIC08A.png"];
    imgSlotArray[25]      = [UIImage imageNamed:@"PIC08B.png"];
    imgSlotArray[26]      = [UIImage imageNamed:@"PIC08C.png"];
    imgSlotArray[27]      = [UIImage imageNamed:@"PIC09A.png"];
    imgSlotArray[28]      = [UIImage imageNamed:@"PIC09B.png"];
    imgSlotArray[29]      = [UIImage imageNamed:@"PIC09C.png"];
    // スロット画像 待避
    for(int i=0; i < C_MAX_IMAGE;i++){
        for(int j = 0; j < C_MAX_SLOT; j++){
            slotView[j][i] = [[UIImageView alloc] initWithImage:imgSlotArray[i]];
        }
    }
    // メダル画像 待避
    for(int i=0; i < C_MAX_MEDAL;i++){
        medalView[i] = [[UIImageView alloc] initWithImage:imgManyMedal[i]];
    }
    //ボタン作成
    stopButton1 =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopButton2 =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopButton3 =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    settingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    startButton =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    slotButton1 =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    slotButton2 =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    slotButton3 =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
}

// サウンドを再生する
- (void)playSound:(int)argValue
{
    if(propertyDef.SoundPresence){
        AudioServicesPlaySystemSound(argValue);
    }
}

// サウンドを停止する
- (void)stopSound:(int)argValue
{
    if(propertyDef.SoundPresence){
        AudioServicesDisposeSystemSoundID(argValue);
    }
}

// appDelegate よりコールされた
- (void)callFromAppDelegate
{
    [self setInitial];
    // ボタン制御
    [self buttonEnabled:C_WAIT];
    
    // スロット表示
    slotIndex0--;
    slotIndex1--;
    slotIndex2--;
    [self startAnimationZero];
    [self startAnimationOne];
    [self startAnimationTwo];
}

// 後処理
- (void)dealloc
{
    int i;
    
    // スロット画像解放
    for(i=0; i < C_MAX_IMAGE;i++){
        for(int j = 0; j < C_MAX_SLOT; j++){
            slotView[j][i].image = nil;
            slotView[j][i] = nil;
        }
    }

    // メダル画像解放
    for(i=0; i < C_MAX_MEDAL;i++){
        medalView[i].image = nil;
        medalView[i] = nil;
    }
    
    // スロットタイマー解放
    for(int i=0; i < C_MAX_SLOT; i++){
        if(slotTimer[i] != nil){
            [slotTimer[i] invalidate];
            slotTimer[i] = nil;
            NSLog(@"slotTimer[%d] free.",i);
        }
    }

    // OKタイマー解放
    if(resultOkTimer != nil){
        [resultOkTimer invalidate];
        resultOkTimer = nil;
        NSLog(@"resultOkTimer free.");
    }

    // NGタイマー解放
    if(resultNgTimer != nil){
        [resultNgTimer invalidate];
        resultNgTimer = nil;
        NSLog(@"resultNgTimer free.");
    }
}

// メモリー異常
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

@end
