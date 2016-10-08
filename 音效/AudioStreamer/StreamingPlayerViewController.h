//
//  StreamingPlayerViewController.h
//  音效
//
//  Created by Jeremy on 16/8/25.
//  Copyright © 2016年 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AudioStreamer,LevelMeterView;
@interface StreamingPlayerViewController : UIViewController
{
     UITextField *downloadSourceField;
     UIButton *button_pause;
     UIView *volumeSlider;
     UILabel *positionLabel;
     UISlider *progressSlider;
     UISlider *columeSliders;
     UITextField *metadataArtist;
     UITextField *metadataTitle;
     UITextField *metadataAlbum;
    AudioStreamer *streamer;
    NSTimer *progressUpdateTimer;
    NSTimer *levelMeterUpdateTimer;
    LevelMeterView *levelMeterView;
    NSString *currentArtist;
    NSString *currentTitle;
}

@property (retain) NSString* currentArtist;
@property (retain) NSString* currentTitle;

- (void)buttonPressed:(id)sender;
- (void)spinButton;
- (void)forceUIUpdate;
- (void)createTimers:(BOOL)create;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)updateProgress:(NSTimer *)updatedTimer;
- (void)sliderMoved:(UISlider *)aSlider;
- (void)volumeSlider:(id)sender;@end
