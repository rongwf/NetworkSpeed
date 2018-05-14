//
//  NetworkSpeedViewController.m
//  OfficeManager
//
//  Created by rongwf on 2018/5/8.
//  Copyright © 2018年 rongwf. All rights reserved.
//

#import "NetworkSpeedViewController.h"
#import "ClockDialView.h"
#import "MeasurNetTools.h"
#import "QBTools.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kkFont35 [UIFont systemFontOfSize:35]
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface NetworkSpeedViewController ()

@property (weak, nonatomic) IBOutlet ClockDialView *clockDiaView;

@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@property (weak, nonatomic) IBOutlet UILabel *uploadLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;

@end

@implementation NetworkSpeedViewController
/*获取网络流量信息*/
- (NSString *) getInterfaceBytes {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return 0;
    }
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        /* Not a loopback device. */
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            //下行
            iBytes += if_data->ifi_ibytes;
            //上行
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
//    NSLog(@"\n[getInterfaceBytes-Total]%@,%@",[QBTools formattedFileSize:iBytes/1024],[QBTools formattedFileSize:oBytes/1024]);
    
    return [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:oBytes/1024]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.barTintColor = RGBA(255, 153, 0, 1);
    bar.translucent = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)startTestSpeed:(id)sender {
    self.downloadLabel.text = @"0.00MB/S";
    self.uploadLabel.text = @"0.00MB/S";
    WS(weakSelf);
    MeasurNetTools * meaurNet = [[MeasurNetTools alloc] initWithblock:^(float speed) {
        NSString* speedStr = [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:speed]];
        NSLog(@"即使速度%@", speedStr);
        NSLog(@"上行速度%@", [weakSelf getInterfaceBytes]);
        weakSelf.downloadLabel.text = speedStr;
        weakSelf.uploadLabel.text = [weakSelf getInterfaceBytes];
        CGFloat networkSpeed = 0.0;
        if ([[QBTools formattedFileSize:speed] containsString:@"KB"]) {
            networkSpeed = [[QBTools formattedFileSize:speed] floatValue] / 1024;
        }
        if ([[QBTools formattedFileSize:speed] containsString:@"bytes"]) {
            networkSpeed = [[QBTools formattedFileSize:speed] floatValue] / 1024 / 1024;
        }
        if ([[QBTools formattedFileSize:speed] containsString:@"GB"]) {
            networkSpeed = [[QBTools formattedFileSize:speed] floatValue] * 1024;
        } else {
            networkSpeed = [[QBTools formattedFileSize:speed] floatValue];
        }
        [weakSelf.clockDiaView refreshDashboard:networkSpeed];
    } finishMeasureBlock:^(float speed) {
//        NSString* speedStr = [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:speed]];
//        NSLog(@"平均速度为：%@",speedStr);
//        NSLog(@"相当于带宽：%@",[QBTools formatBandWidth:speed]);
    } failedBlock:^(NSError *error) {
        
    }];
    
    [meaurNet startMeasur];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.barTintColor = RGBA(255, 255, 255, 1);
    bar.translucent = NO;

    self.clockDiaView.minValue = 0;
    self.clockDiaView.maxValue = 10;
    
    self.downloadLabel.font = kkFont35;
    self.uploadLabel.font = kkFont35;
    
    [self.clockDiaView drawArcWithStartAngle:-M_PI_4*5 endAngle:M_PI_4 lineWidth:2.0f fillColor:[UIColor clearColor] strokeColor:RGBA(255, 255, 255, 0.5)];
    //刻度
    [self.clockDiaView drawScaleWithDivide:100 andRemainder:10 strokeColor:RGBA(255, 255, 255, 0.5) filleColor:[UIColor clearColor]scaleLineNormalWidth:5 scaleLineBigWidth:10];
    // 增加刻度值
    [self.clockDiaView DrawScaleValueWithDivide:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
