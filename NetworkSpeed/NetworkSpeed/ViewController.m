//
//  ViewController.m
//  NetworkSpeed
//
//  Created by rongwf on 2018/5/10.
//  Copyright © 2018年 rongwf. All rights reserved.
//

#import "ViewController.h"
#import "NetworkSpeedViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)button:(id)sender {
    NetworkSpeedViewController *vc = [[NetworkSpeedViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
