//
//  YLShareViewController.m
//  LookOtherDemo
//
//  Created by denglibing on 2017/1/12.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import "YLShareViewController.h"

@interface YLShareViewController ()
{
    UITextField *shakeCountTF;
    UITextField *shakeIntervalTF;
}

@end

@implementation YLShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"摇一摇设置";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger shakeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"YLShareViewController_count"] integerValue];
    CGFloat shakeInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"YLShareViewController_interval"] floatValue];
    
    shakeCountTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 300, 40)];
    shakeCountTF.font = [UIFont systemFontOfSize:14];
    shakeCountTF.placeholder = [NSString stringWithFormat:@"输入摇一摇次数, 当前是 %d 次", (int)shakeCount];
    shakeCountTF.borderStyle = UITextBorderStyleRoundedRect;
    shakeCountTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:shakeCountTF];
    
    shakeIntervalTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, 300, 40)];
    shakeIntervalTF.font = [UIFont systemFontOfSize:14];
    shakeIntervalTF.placeholder = [NSString stringWithFormat:@"输入摇一摇间隔, 当前是 %0.2f 秒/次", shakeInterval];
    shakeIntervalTF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:shakeIntervalTF];
    
    [self showRightItemWithTitle:@"完成" color:[UIColor blackColor] selector:@selector(done)];
}


- (void)showRightItemWithTitle:(NSString *) title color:(UIColor *)color selector:(SEL) selector{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, 80, 32)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)done{
    
    [[NSUserDefaults standardUserDefaults] setValue:shakeCountTF.text forKey:@"YLShareViewController_count"];
    [[NSUserDefaults standardUserDefaults] setValue:shakeIntervalTF.text forKey:@"YLShareViewController_interval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
