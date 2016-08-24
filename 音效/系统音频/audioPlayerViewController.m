//
//  audioPlayerViewController.m
//  音效
//
//  Created by Jeremy on 16/8/24.
//  Copyright © 2016年 Jeremy. All rights reserved.
//

#import "audioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#define kMusicFile @"11aa.mp3"
#define kMusicSinger @"刘若英"
#define kMusicTitle @"原来你也在这里"
@interface audioPlayerViewController ()<AVAudioPlayerDelegate>
@property(nonatomic,strong) AVAudioPlayer *audioPlayer; //播放器
@property(retain,nonatomic) UILabel *controlPanel; //控制面板
@property (retain, nonatomic) UIProgressView *playProgress;//播放进度
@property (retain, nonatomic) UILabel *musicSinger; //演唱者
@property (retain, nonatomic) UIButton *playOrPause; //播放/暂停按钮(如果tag为0认为是暂停状态，1是播放状态)

@property (weak ,nonatomic) NSTimer *timer;//进度更新定时器
@end

@implementation audioPlayerViewController
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    UIView *viewTop = [[UIView alloc]init];
    viewTop.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:101.0/255.0 blue:101.0/255.0 alpha:0.5];
 
    [self.view addSubview:viewTop];
    
    [viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@64);
    }];
    
    
    UILabel *lab_title = [[UILabel alloc]init];
    lab_title.text = kMusicTitle;
    lab_title.textColor = [UIColor whiteColor];
    lab_title.textAlignment = NSTextAlignmentCenter;
    lab_title.font = [UIFont systemFontOfSize:14];
    [viewTop addSubview:lab_title];
    
    [lab_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewTop.mas_left).with.offset(0);
        make.right.equalTo(viewTop.mas_right).with.offset(0);
        make.bottom.equalTo(viewTop.mas_bottom).with.offset(-5);
        make.height.mas_equalTo(@20);
    }];
    

    
    
    UIView *view_bottom = [[UIView alloc]init];
    view_bottom.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:101.0/255.0 blue:101.0/255.0 alpha:0.5];
   
    [self.view addSubview:view_bottom];
    
    [view_bottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-48);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@164);

    }];
    
    
    UILabel *musicSinger = [[UILabel alloc]init];
    musicSinger.text = kMusicSinger;
    musicSinger.textColor = [UIColor whiteColor];
    [view_bottom addSubview:musicSinger];
    self.musicSinger = musicSinger;
    [musicSinger mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view_bottom.mas_left).with.offset(10);
        make.top.equalTo(view_bottom.mas_top).with.offset(10);
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@20);
    }];
    
    
    
    
    self.playProgress = [[UIProgressView alloc]init];
    self.playProgress.progress = 0.5;
    [view_bottom addSubview:self.playProgress];
    
    [self.playProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view_bottom.mas_left).with.offset(0);
        make.right.equalTo(view_bottom.mas_right).with.offset(0);
        make.height.mas_equalTo(@2);
        make.top.equalTo(musicSinger.mas_bottom).with.offset(10);
    }];
    
    
    self.playOrPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playOrPause setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];

    [self.playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    self.playOrPause.tag=0;
    [view_bottom addSubview:self.playOrPause];
    
    [self.playOrPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playProgress.mas_bottom).with.offset(10);
        make.centerX.mas_equalTo(view_bottom.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    
    [self setupUI];
}
/**
 *  初始化UI
 */
-(void)setupUI{
//    self.title=kMusicTitle;
    self.musicSinger.text=kMusicSinger;
    
    
    
    
    
    UIImageView *backView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backView.image = [UIImage imageNamed:@"11.jpg"];
    [self.view insertSubview:backView atIndex:0];
  
    
}
/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:kMusicFile ofType:nil];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
        _audioPlayer.delegate=self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}
/**
 *  播放音频
 */
-(void)play{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        self.timer.fireDate=[NSDate distantPast];//恢复定时器
    }
}
/**
 *  暂停播放
 */
-(void)pause{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        
    }
}
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (IBAction)playClick:(UIButton *)sender {
    if(sender.tag){
        sender.tag=0;
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        [self pause];
    }else{
        sender.tag=1;
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
        [self play];
    }
}
/**
 *  更新播放进度
 */
-(void)updateProgress{
    float progress= self.audioPlayer.currentTime /self.audioPlayer.duration;
    [self.playProgress setProgress:progress animated:true];
}


/**
 *  显示当面视图控制器时注册远程事件
 *
 *  @param animated 是否以动画的形式显示
 */
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //开启远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //作为第一响应者
    //[self becomeFirstResponder];
}
/**
 *  当前控制器视图不显示时取消远程控制
 *
 *  @param animated 是否以动画的形式消失
 */
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    //[self resignFirstResponder];
}

/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self pause];
        }
    }
    
    //    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //        NSLog(@"%@:%@",key,obj);
    //    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
//    [[AVAudioSession sharedInstance]setActive:NO error:nil];
    
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
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
