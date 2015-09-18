//
//  GesturePasswordView.h
//  GesturePassword
//
//  Created by AD-iOS on 15/7/17.
//  Copyright (c) 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GestureMode) {
    GestureModeSetPassword = 0, //设置密码
    GestureModeVerifyPassword, //验证密码
    GestureModeModifyPassword, //修改密码
};

@protocol GesturePasswordViewDelegate ;

@interface GesturePasswordView : UIView

@property (assign, nonatomic) GestureMode mode;

@property (nonatomic, weak) id<GesturePasswordViewDelegate>delegate;

/**
 *  9个基础点的颜色，默认灰色，不建议设置透明色
 */
@property (nonatomic, strong) UIColor *basePointColor;
/**
 *  被选中的时候点的颜色，默认白色
 */
@property (nonatomic, strong) UIColor *lightPointColor;
/**
 *  选中时圆周围的颜色，默认白色透明
 */
@property (nonatomic, strong) UIColor *pointCircleColor;
/**
 *  线的颜色
 */
@property (nonatomic, strong) UIColor *lineColor;
/**
 *  密码错误时使用的颜色
 */
@property (nonatomic, strong) UIColor *wrongTintColor;

//手势区域距离view顶部的距离，默认50，最小距离应设置为选中点所画图形的半径
@property (nonatomic, assign) CGFloat topInset;
//手势区域距离左边view的距离，默认50，右边和左边相同，不用设置
@property (nonatomic, assign) CGFloat leftInset;

@property (nonatomic, copy) NSString *pwdStr;


@end

@protocol GesturePasswordViewDelegate <NSObject>

@optional
/**
 *  修改密码模式验证密码成功后的回调，在修改密码模式时实现
 */
- (void)gesturePasswordViewChangePasswordModeVerifyPasswordSucced;


@required

/**
 * 是否已经设置过密码，在其中改变提示内容
 */
- (void)gesturePasswordViewHadSetPassword;
/**
 *  是否判断了密码的正确性
 *
 *  @param isCorrect YES密码正确，NO密码错误
 */
- (void)gesturePasswordViewDidCheckPassword:(BOOL)isCorrect;

@end