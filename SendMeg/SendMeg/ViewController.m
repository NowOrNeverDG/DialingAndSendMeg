//
//  ViewController.m
//  SendMeg
//
//  Created by 丁戈 on 2017/2/6.
//  Copyright © 2017年 BTeam. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
@import CoreTelephony;


@interface ViewController ()<MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *carrierName;
@property (weak, nonatomic) IBOutlet UILabel *mobileCountryCode;
@property (weak, nonatomic) IBOutlet UILabel *ISOCountryCode;
@property (weak, nonatomic) IBOutlet UILabel *allowsVOIP;
@property (weak, nonatomic) IBOutlet UILabel *mobileNetworkCode;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@end

@implementation ViewController
{
    CTCallCenter *_callCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 发短信给10086
-(void)sendMessage {
    //用于判断是否有发送短信的功能（模拟器上就没有短信功能）
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    //判断是否有短信功能
    if (messageClass != nil) {
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        
        //拼接并设置短信内容
        NSString *messageContent = [NSString stringWithFormat:@"蛤蛤蛤蛤蛤蛤"];
        messageController.body = messageContent;
        
        //设置发送给谁
        messageController.recipients = @[@"10086"];
        
        //推到发送视图控制器
        [self presentViewController:messageController animated:YES completion:^{
            
        }];
        
    } else {
        UIAlertController* alertView = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"iOS版本过低"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {}];
        [alertView addAction:cancelAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

//发送短信后回调的方法
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
             case MessageComposeResultCancelled:
                 NSLog(@"返回APP界面") ;
                 break;
    
            case MessageComposeResultFailed:
                 NSLog(@"发送短信失败") ;
                 break;
    
             case MessageComposeResultSent:
                 NSLog(@"发送成功") ;
                 break;
             default:
                 break;
    }
    
    //最后解除SMS的系统发送界面，返回原app
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)sendMegAction:(UIButton *)sender {
    [self sendMessage];
}

#pragma mark - 拨打10086
- (IBAction)openDialingInterface:(UIButton *)sender {
    NSString *allString = [NSString stringWithFormat:@"tel:10086"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:allString]];
    [self getCarrierInfo];
    [self callStatus];
}

-(void)callStatus {//监听电话状态
    //获取电话接入信息
    _callCenter.callEventHandler = ^(CTCall *call){
        if ([call.callState isEqualToString:CTCallStateDisconnected]){
            NSLog(@"电话没有连接");
            
        }else if ([call.callState isEqualToString:CTCallStateConnected]){
            NSLog(@"电话已经连接");
            
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            NSLog(@"电话正在连接");
            
        }else if ([call.callState isEqualToString:CTCallStateDialing]){
            NSLog(@"电话正在拨号");
        }else{
            NSLog(@"不清楚电话在干嘛");
        }
    };
}

-(void)getCarrierInfo {
    // 获取运营商信息
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSLog(@"carrier:%@", [carrier description]);
    
    // 如果运营商变化将更新运营商输出
    info.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
        NSLog(@"carrier:%@", [carrier description]);
    };
    
    // 输出手机的数据业务信息
    NSLog(@"Radio Access Technology:%@", info.currentRadioAccessTechnology);
    self.carrierName.text = carrier.carrierName;
    self.mobileCountryCode.text = carrier.mobileCountryCode;
    self.ISOCountryCode.text = carrier.isoCountryCode;
    self.mobileNetworkCode.text = carrier.mobileNetworkCode;
    if (carrier.allowsVOIP == YES) {self.allowsVOIP.text = @"YES";
    } else { self.allowsVOIP.text = @"NO"; }
    
    NSString *commcenter = @"/private/var/wireless/Library/Preferences/com.apple.commcenter.plist";
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:commcenter];
    NSString *PhoneNumber = [dict valueForKey:@"PhoneNumber"];
    NSLog([NSString stringWithFormat:@"Phone number: %@",PhoneNumber],nil);
}
@end
