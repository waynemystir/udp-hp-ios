//
//  VideoCallViewController.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 4/16/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCEAGLVideoView.h"
#import <AppRTC/ARDAppClient.h>

@interface VideoCallViewController : UIViewController <ARDAppClientDelegate, RTCEAGLVideoViewDelegate>

@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewBottomConstraint;
@property (strong, nonatomic) NSString *serverHostUrl;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) ARDAppClient *client;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (assign, nonatomic) CGSize localVideoSize;
@property (assign, nonatomic) CGSize remoteVideoSize;
@property (assign, nonatomic) BOOL isZoom; //used for double tap remote view

//togle button parameter
@property (assign, nonatomic) BOOL isAudioMute;
@property (assign, nonatomic) BOOL isVideoMute;

- (IBAction)audioButtonPressed:(id)sender;
- (IBAction)videoButtonPressed:(id)sender;
- (IBAction)hangupButtonPressed:(id)sender;

@end
