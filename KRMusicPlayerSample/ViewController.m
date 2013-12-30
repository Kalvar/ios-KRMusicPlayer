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

@synthesize musicPlayer;
@synthesize outAlbumNameLabel;
@synthesize outSongNameLabel;
@synthesize outSongLengthLabel;
@synthesize outSongVolumeLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    musicPlayer = [KRMusicPlayer sharedManager];
    //musicPlayer = [[KRMusicPlayer alloc] init];
    [self.musicPlayer initialize];
    [self.musicPlayer setPlaybackChangeHandler:^(BOOL stop, MPMusicPlaybackState playbackState) {
        
        NSLog(@"setPlaybackChangeHandler : %i", playbackState);
        
        switch ( playbackState )
        {
            case MPMusicPlaybackStateStopped:
                //完全停止 ( iPod Music Player 會退回到音樂的列表畫面 )
                
                break;
            case MPMusicPlaybackStatePlaying:
                //正在播放
                
                break;
            case MPMusicPlaybackStatePaused:
                //已暫停
                
                break;
            case MPMusicPlaybackStateInterrupted:
                //已中斷
                
                break;
            case MPMusicPlaybackStateSeekingForward:
                //正向播放
                
                break;
            case MPMusicPlaybackStateSeekingBackward:
                //逆向播放
                
                break;
            default:
                break;
        }
    }];
    
    //If you wanna use blocks to control __strong or main-thread elements ( objects ) that you need to use __weak to autorelease the memories.
    __weak KRMusicPlayer *_musicPlayer  = musicPlayer;
    __weak UILabel *_outSongNameLabel   = outSongNameLabel;
    __weak UILabel *_outAlbumNameLabel  = outAlbumNameLabel;
    __weak UILabel *_outSongLengthLabel = outSongLengthLabel;
    [self.musicPlayer setPlayingItemChangeHandler:^(NSString *itemPersistentId) {
        
        NSLog(@"setPlayingItemChangeHandler : %@", itemPersistentId);
        
        //取得歌曲名稱 ( Fetchs Song Name of Playing. )
        NSString *_playingSong = [_musicPlayer getPlayingSongName];
        
        //取得專輯名稱 ( Fetchs Album Name of Playing. )
        NSString *_playingAlbum = [_musicPlayer getPlayingAlbumName];
        
        //取得歌曲播放時間總長度 ( Fetchs Song Length with Seconds. )
        CGFloat _playingTimeLength = [_musicPlayer getPlayingSongDuration];
        
        [_outSongNameLabel setText:_playingSong];
        [_outAlbumNameLabel setText:_playingAlbum];
        [_outSongLengthLabel setText:[NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:_playingTimeLength] stringValue]]];
        
        //Save the Song that you can use [_musicPlayer playSavedSongLists] to play the saved songs.
        [_musicPlayer savePlaylistWithPersistentId:itemPersistentId];
        //You can use this method to get all saved songs.
        //NSDictionary *_savedSongs = [_musicPlayer getSavedSongLists];
        
    }];
    
    __weak UILabel *_outSongVolumeLabel = outSongVolumeLabel;
    [self.musicPlayer setVolumeChangeHandler:^(CGFloat volume) {
        
        NSLog(@"setVolumeChangeHandler : %f", volume);
        [_outSongVolumeLabel setText:[NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:volume] stringValue]]];
        
    }];

    //是否正在播放中 ( Music is Playing ? )
    if( self.musicPlayer.isPlaying )
    {
        // ... 
    }
    
    //是否是暫停播放 ( 或停止播放, Music is Paused ? )
    if( self.musicPlayer.isPause )
    {
        // ... 
    }
    
    [self.musicPlayer awakePlayer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark IBActions
-(IBAction)play:(id)sender
{
    //播放音樂 ( Play Music )
    if( musicPlayer.isStop || musicPlayer.isPause )
    {
        [musicPlayer play];
    }
}

-(IBAction)stop:(id)sender
{
    //暫停播放 ( Pause Music )
    [musicPlayer pause];
}

-(IBAction)next:(id)sender
{
    //下一首歌 ( Next Song. )
    [musicPlayer nextSong];
}

-(IBAction)previous:(id)sender
{
    //上一首歌 ( Previous Song. )
    [musicPlayer previousSong];
}

-(IBAction)playLists:(id)sender
{
    [musicPlayer playSavedSongLists];
}

-(IBAction)playMusic:(id)sender
{
    [musicPlayer playSongWithPersistenId:@"persistenId of song."];
}

-(IBAction)fetchAllSongs:(id)sender
{
    NSLog(@"all songs : %@", [musicPlayer fetchAllSongs]);
}

-(IBAction)fetchAllAlbums:(id)sender
{
    NSLog(@"all albums : %@", [musicPlayer fetchAllAlbums]);
}

-(IBAction)fetchAlbumSongs:(id)sender
{
    NSNumber *_albumId = [NSNumber numberWithLongLong:[@"-843583648929542851" longLongValue]];
    NSLog(@"取得指定專輯的所有歌曲 : %@", [musicPlayer fetchAlbumSongsWithAlbumId:_albumId]);
}

@end
