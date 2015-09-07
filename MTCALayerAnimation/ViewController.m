//
//  ViewController.m
//  MTCALayerAnimation
//
//  Created by mtt0150 on 15/9/6.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import "ViewController.h"
#define WIDTHANDHEIGHT 150
#import "KUIView.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    KUIView *view = [[KUIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.layer.contents = (id)[UIImage imageNamed:[[NSBundle mainBundle] pathForResource:@"background.jpg" ofType:nil]].CGImage;
    [self.view addSubview:view];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //创建一个UIview
    
}

@end
