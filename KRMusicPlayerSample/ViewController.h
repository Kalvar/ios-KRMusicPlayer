//
//  ViewController.h
//  KRMusicPlayerSample
//
//  Created by Kalvar on 13/9/13.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KRMusicPlayer;

@interface ViewController : UIViewController
{
    KRMusicPlayer *musicPlayer;
}

@property (nonatomic, strong) KRMusicPlayer *musicPlayer;
@property (nonatomic, weak) IBOutlet UILabel *outAlbumNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *outSongNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *outSongLengthLabel;
@property (nonatomic, weak) IBOutlet UILabel *outSongVolumeLabel;


@end
