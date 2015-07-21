//
//  ViewController.m
//  GesturePassword
//
//  Created by AD-iOS on 15/7/17.
//  Copyright (c) 2015年 Adinnet. All rights reserved.
//

#import "ViewController.h"
#import "GesturePasswordView.h"

@interface ViewController ()<GesturePasswordViewDelegate>

@property (nonatomic,strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GesturePasswordView *view = [[GesturePasswordView alloc]initWithFrame:self.view.frame];
    view.backgroundColor = [UIColor darkGrayColor];
    view.delegate = self;
    view.basePointColor = [UIColor redColor];
    view.leftInset = 30;
    view.mode = GestureModeModifyPassword;
    [self.view addSubview:view];
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 500, 400, 20)];
    self.label.textColor = [UIColor whiteColor];
    self.label.text = @"请输入密码";
    [self.view addSubview:self.label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gesturePasswordViewHadSetPassword
{
    self.label.text = @"请再次输入密码";
}

- (void)gesturePasswordViewDidCheckPassword:(BOOL)isCorrect
{
    if (isCorrect) {
        self.label.text = @"密码正确";
    }else{
        self.label.text = @"密码错误，请重试";
    }
}

- (void)gesturePasswordViewChangePasswordModeVerifyPasswordSucced
{
    self.label.text = @"密码正确，请重新设置密码";
}

@end
