//
//  ViewController.m
//  KRMusicPlayerSample
//
//  Created by Kalvar on 13/9/13.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"
#import "KRMusicPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    KRMusicPlayer *musicPlayer = [KRMusicPlayer sharedManager];
    //播放音樂 ( Play Music )
    [musicPlayer play];
    //停止播放 ( Stop Music )
    [musicPlayer stop];
    //取得歌曲名稱 ( Fetchs Song Name of Playing. )
    NSString *_playingSong = [musicPlayer getPlayingSong];
    //取得專輯名稱 ( Fetchs Album Name of Playing. )
    NSString *_playingAlbum = [musicPlayer getPlayingAlbum];
    //取得歌曲播放時間總長度 ( Fetchs Song Length with Seconds. )
    CGFloat _playingTimeLength = [musicPlayer getPlayingSongDuration];
    //下一首歌 ( Next Song. )
    [musicPlayer nextSong];
    //上一首歌 ( Previous Song. )
    [musicPlayer previousSong];
    //是否正在播放中 ( Music is Playing ? )
    if( musicPlayer.isPlaying )
    {
        // ... 
    }
    
    //是否是暫停播放 ( 或停止播放, Music is Paused ? )
    if( musicPlayer.isPause )
    {
        // ... 
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
