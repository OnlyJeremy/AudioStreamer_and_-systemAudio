//
//  StreamingPlayerViewController.m
//  音效
//
//  Created by Jeremy on 16/8/25.
//  Copyright © 2016年 Jeremy. All rights reserved.
//

#import "StreamingPlayerViewController.h"
#import "Masonry.h"
#import "AudioStreamer.h"
#import "LevelMeterView.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
@interface StreamingPlayerViewController ()

@end

@implementation StreamingPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    button_pause = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_pause setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
    [button_pause addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_pause];
    [button_pause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.equalTo(self.view).with.offset(70);
    }];
    
}
- (void)buttonPressed:(id)sender
{
    if ([button_pause.currentImage isEqual:[UIImage imageNamed:@"playbutton.png"]] || [button_pause.currentImage isEqual:[UIImage imageNamed:@"pausebutton.png"]])
    {
        [downloadSourceField resignFirstResponder];
        
        [self createStreamer];
        [self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
        [streamer start];
    }
    else
    {
        [streamer stop];
    }
}
//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
    [button_pause.layer removeAllAnimations];
    if (!image)
    {
        [button_pause setImage:[UIImage imageNamed:@"playbutton.png"] forState:0];
    }
    else
    {
        [button_pause setImage:image forState:0];
        
        if ([button_pause.currentImage isEqual:[UIImage imageNamed:@"loadingbutton.png"]])
        {
            [self spinButton];
        }
    }
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
    if (streamer)
    {
        return;
    }
    
    [self destroyStreamer];
    
    NSString *escapedValue =
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                          nil,
                                                                          (CFStringRef)@"http://sc.111ttt.com/up/mp3/93409/189511287B7FAEE4416BF9244E69F972.mp3",
                                                                          NULL,
                                                                          NULL,
                                                                          kCFStringEncodingUTF8))
     ;
    
    NSURL *url = [NSURL URLWithString:escapedValue];
    streamer = [[AudioStreamer alloc] initWithURL:url];
    
    [self createTimers:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
#ifdef SHOUTCAST_METADATA
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(metadataChanged:)
     name:ASUpdateMetadataNotification
     object:streamer];
#endif
}
//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
    if (streamer)
    {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
        [self createTimers:NO];
        
        [streamer stop];
//        [streamer release];
        streamer = nil;
    }
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
