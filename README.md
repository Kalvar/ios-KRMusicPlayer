## Supports

KRMusicPlayer supports ARC.

## How To Get Started

KRMusicPlayer is using simple methods to control iPod Music Player of iOS.

``` objective-c
//ViewController.h
@class KRMusicPlayer;

@interface ViewController : UIViewController
{
    KRMusicPlayer *musicPlayer;
}

@property (nonatomic, strong) KRMusicPlayer *musicPlayer;
@property (nonatomic, weak) IBOutlet UILabel *outSongNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *outAlbumNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *outSongLengthLabel;

@end

//ViewController.m
#import "KRMusicPlayer.h"

@implementation ViewController

@synthesize musicPlayer;
@synthesize outSongNameLabel;
@synthesize outAlbumNameLabel;
@synthesize outSongLengthLabel;

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
        NSString *_playingSong = [_musicPlayer getPlayingSong];
        
        //取得專輯名稱 ( Fetchs Album Name of Playing. )
        NSString *_playingAlbum = [_musicPlayer getPlayingAlbum];
        
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
```

## Version

KRMusicPlayer now is V0.7 beta.

## License

KRMusicPlayer is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.
