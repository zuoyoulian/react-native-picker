//
//  RCTBEEPickerManager.m
//  RCTBEEPickerManager
//
//  Created by MFHJ-DZ-001-417 on 16/9/6.
//  Copyright © 2016年 MFHJ-DZ-001-417. All rights reserved.
//

#import "RCTBEEPickerManager.h"
#import "BzwPicker.h"
#import <React/RCTEventDispatcher.h>

@interface RCTBEEPickerManager()

@property(nonatomic,strong)BzwPicker *pick;
@property(nonatomic,strong)UIButton *bgButton;
@property(nonatomic,assign)float height;
@property(nonatomic,weak)UIWindow * window;

@end

@implementation RCTBEEPickerManager

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(_init:(NSDictionary *)indic){
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
    });
    
    self.window = [UIApplication sharedApplication].keyWindow;
    
    NSString *pickerConfirmBtnText=indic[@"pickerConfirmBtnText"];
    NSString *pickerCancelBtnText=indic[@"pickerCancelBtnText"];
    NSString *pickerTitleText=indic[@"pickerTitleText"];
    NSString *pickerSubTitleText=indic[@"pickerSubTitleText"];
    NSArray *pickerConfirmBtnColor=indic[@"pickerConfirmBtnColor"];
    NSArray *pickerCancelBtnColor=indic[@"pickerCancelBtnColor"];
    NSArray *pickerTitleColor=indic[@"pickerTitleColor"];
    NSArray *pickerSubTitleColor=indic[@"pickerSubTitleColor"];
    NSArray *pickerToolBarBg=indic[@"pickerToolBarBg"];
    NSArray *pickerBg=indic[@"pickerBg"];
    NSArray *selectArry=indic[@"selectedValue"];
    NSArray *weightArry=indic[@"wheelFlex"];
    NSString *pickerToolBarFontSize=[NSString stringWithFormat:@"%@",indic[@"pickerToolBarFontSize"]];
    NSString *pickerFontSize=[NSString stringWithFormat:@"%@",indic[@"pickerFontSize"]];
    NSString *pickerSubTitleFontSize=[NSString stringWithFormat:@"%@",indic[@"pickerSubTitleFontSize"]];
    NSString *pickerFontFamily=[NSString stringWithFormat:@"%@",indic[@"pickerFontFamily"]];
    NSArray *pickerFontColor=indic[@"pickerFontColor"];
    NSString *pickerRowHeight=indic[@"pickerRowHeight"];
    id pickerData=indic[@"pickerData"];
    
    NSMutableDictionary *dataDic=[[NSMutableDictionary alloc]init];
    
    dataDic[@"pickerData"]=pickerData;
    
    [self.window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[BzwPicker class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [obj removeFromSuperview];
            });
        }
        
    }];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0 ) {
        self.height=280;
    }else{
        self.height=250;
    }
    
    // 先移除子视图
    if (_bgButton) {
        [_bgButton removeFromSuperview];
    }
    if (_pick) {
        [_pick removeFromSuperview];
    }
    NSLog(@"pickerToolBarFontSize = %@", pickerToolBarFontSize);
    self.pick=[[BzwPicker alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.height) dic:dataDic leftStr:pickerCancelBtnText centerStr:pickerTitleText rightStr:pickerConfirmBtnText topbgColor:pickerToolBarBg bottombgColor:pickerBg leftbtnbgColor:pickerCancelBtnColor rightbtnbgColor:pickerConfirmBtnColor centerbtnColor:pickerTitleColor selectValueArry:selectArry weightArry:weightArry pickerToolBarFontSize:pickerToolBarFontSize pickerFontSize:pickerFontSize pickerFontColor:pickerFontColor  pickerRowHeight: pickerRowHeight pickerFontFamily:pickerFontFamily centerSubStr:pickerSubTitleText centerSubColor:pickerSubTitleColor centerSubFontSize:pickerSubTitleFontSize];
    
    self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bgButton.frame = self.window.bounds;
    [self.bgButton setBackgroundColor:[UIColor blackColor]];
    self.bgButton.alpha = 0.5;
    [self.bgButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    __weak __typeof(&*self)weakSelf = self;
    _pick.bolock=^(NSDictionary *backinfoArry,  BOOL hiddePick){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hiddePick) {
                [weakSelf hide];
            }
            [weakSelf.bridge.eventDispatcher sendAppEventWithName:@"pickerEvent" body:backinfoArry];
        });
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.window addSubview:_bgButton];
        [weakSelf.window addSubview:_pick];
    });
    
}

RCT_EXPORT_METHOD(show){
    if (self.pick) {
        __weak __typeof(&*self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.bgButton.alpha = 0.5;
                [_pick setFrame:CGRectMake(0, SCREEN_HEIGHT-weakSelf.height, SCREEN_WIDTH, weakSelf.height)];
            }];
        });
    }
    return;
}

RCT_EXPORT_METHOD(hide){
    if (self.pick) {
        __weak __typeof(&*self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.bgButton.alpha = 0;
                [_pick setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, weakSelf.height)];
            }];
        });
    }
    
    self.pick.hidden=YES;
    return;
}

RCT_EXPORT_METHOD(select: (NSArray*)data){
    if (self.pick) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _pick.selectValueArry = data;
            [_pick selectRow];
        });
    }return;
}

RCT_EXPORT_METHOD(isPickerShow:(RCTResponseSenderBlock)getBack){
    
    if (self.pick) {
        CGFloat pickY=_pick.frame.origin.y;
        
        if (pickY==SCREEN_HEIGHT) {
            
            getBack(@[@YES]);
        }else
        {
            getBack(@[@NO]);
        }
    }else{
        getBack(@[@"picker不存在"]);
    }
}

@end

