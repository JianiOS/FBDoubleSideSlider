//
//  ViewController.m
//  FBDoubleSideSlider
//
//  Created by 尹健 on 16/6/16.
//  Copyright © 2016年 FenbeiTech. All rights reserved.
//

#import "ViewController.h"
#import "FBDoubleSideSlider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FBDoubleSideSlider* slider = [[FBDoubleSideSlider alloc] initWithFrame:CGRectMake(20, 40, [UIScreen mainScreen].bounds.size.width - 40, 100) SectionTitles:@[@"￥0",@"￥150",@"￥300"/*,@"￥450",@"￥600"*/,@"￥1000",@"不限"]];
    slider.backgroundColor = [UIColor colorWithWhite:0.785 alpha:1.000];
    slider.nonSelectTextColor = [UIColor blackColor];
    slider.selectTextColor = [UIColor whiteColor];
    slider.selectColor = [UIColor greenColor];
    slider.nonSelectColor = [UIColor blackColor];
    [slider setValueChangeBlock:^(NSInteger min, NSInteger max) {
        NSLog(@"%ld  %ld",min,max);
    }];
    [self.view addSubview:slider];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
