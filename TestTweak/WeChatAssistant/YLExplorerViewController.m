//
//  YLExplorerViewController.m
//  WeChatAssistant
//
//  Created by lingyohunl on 16/8/18.
//  Copyright © 2016年 yohunl. All rights reserved.
//

#import "YLExplorerViewController.h"
#import "YLAssitManager.h"
#import "YLGlobalViewController.h"
@interface YLExplorerViewController ()<YLGlobalViewControllerDelegate>
{
    NSInteger shakeCount;
    CGFloat shakeInterval;
}

@end

@implementation YLExplorerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Toolbar
    self.explorerToolbar = [[YLExplorerToolBar alloc] init];
    CGSize toolbarSize = CGSizeMake(160, 50);
    // Start the toolbar off below any bars that may be at the top of the view.
    CGFloat toolbarOriginY = 100.0;
    self.explorerToolbar.frame = CGRectMake(0.0, toolbarOriginY, toolbarSize.width, toolbarSize.height);
    self.explorerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.explorerToolbar];
    
    
    [_explorerToolbar.menuBtn addTarget:self action:@selector(mentAction:) forControlEvents:UIControlEventTouchUpInside];
    [_explorerToolbar.shakeBtn addTarget:self action:@selector(shakeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_explorerToolbar.closrBtn addTarget:self action:@selector(closrBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.movePanGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMovePan:)];
    [self.view addGestureRecognizer:self.movePanGR];
}



- (void)mentAction:(id)sender {
    YLGlobalViewController *vc = [YLGlobalViewController new];
    vc.delegate = self;
    [YLGlobalViewController setApplicationWindow:[[UIApplication sharedApplication] keyWindow]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self makeKeyAndPresentViewController:navigationController animated:YES completion:nil];
    
}

- (void)shakeAction:(id)sender{
    UIViewController *vc = [self getCurrentVC];
    
    shakeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"YLShareViewController_count"] integerValue];
    shakeInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"YLShareViewController_interval"] floatValue];
    
    if (shakeCount <= 0) {
        shakeCount = 100;
    }
    
    if (shakeInterval <= 0) {
        shakeInterval = 0.1;
    }
    
    NSInteger i = 0;
    while (i < shakeCount) {
        i++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(shakeInterval * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [vc motionBegan:UIEventSubtypeMotionShake withEvent:nil];
            [vc motionEnded:UIEventSubtypeMotionShake withEvent:nil];
        });
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
}

- (void)closrBtnAction:(id)sender {
    [[YLAssitManager sharedManager]hideExplorer];
    
}


#pragma mark - Selected View Moving

- (void)handleMovePan:(UIPanGestureRecognizer *)movePanGR
{
    switch (movePanGR.state) {
        case UIGestureRecognizerStateBegan:
            self.selectedViewFrameBeforeDragging = self.explorerToolbar.frame;
            [self updateSelectedViewPositionWithDragGesture:movePanGR];
            break;
            
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            [self updateSelectedViewPositionWithDragGesture:movePanGR];
            break;
            
        default:
            break;
    }
}

- (void)updateSelectedViewPositionWithDragGesture:(UIPanGestureRecognizer *)movePanGR
{
    CGPoint translation = [movePanGR translationInView:self.view];
    CGRect newSelectedViewFrame = self.selectedViewFrameBeforeDragging;
    newSelectedViewFrame.origin.x = (newSelectedViewFrame.origin.x + translation.x);
    newSelectedViewFrame.origin.y = (newSelectedViewFrame.origin.y + translation.y);
    self.explorerToolbar.frame = newSelectedViewFrame;
}



- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates
{
    BOOL shouldReceiveTouch = NO;
    
    CGPoint pointInLocalCoordinates = [self.view convertPoint:pointInWindowCoordinates fromView:nil];
    
    // Always if it's on the toolbar
    if (CGRectContainsPoint(self.explorerToolbar.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    
   
   
    
    // Always if we have a modal presented
    if (!shouldReceiveTouch && self.presentedViewController) {
        shouldReceiveTouch = YES;
    }
    
    return shouldReceiveTouch;
}

- (BOOL)wantsWindowToBecomeKey
{
    return self.previousKeyWindow != nil;
}


#pragma mark - YLGlobalViewControllerDelegate
- (void)globalsViewControllerDidFinish:(YLGlobalViewController *)globalsViewController;{
    [self resignKeyAndDismissViewControllerAnimated:YES completion:nil];
}


- (void)resignKeyAndDismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    UIWindow *previousKeyWindow = self.previousKeyWindow;
    self.previousKeyWindow = nil;
    [previousKeyWindow makeKeyWindow];
    [[previousKeyWindow rootViewController] setNeedsStatusBarAppearanceUpdate];
    
    [self dismissViewControllerAnimated:animated completion:completion];
}

- (void)makeKeyAndPresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    // Save the current key window so we can restore it following dismissal.
    self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    // Make our window key to correctly handle input.
    [self.view.window makeKeyWindow];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // Show the view controller.
    [self presentViewController:viewController animated:animated completion:completion];
}


@end
