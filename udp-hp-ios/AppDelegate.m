//
//  AppDelegate.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 2/26/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthN.h"
#import "udp_client.h"
#import "UdpClientCallbacks.h"
#import "Shared.h"
#import "RTCPeerConnectionFactory.h"
#import "IncomingCallViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    init_app_settings();
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    char env_str[20] = {0};
    get_environment_as_str(env_str);
    char wes[512] = {0};
    sprintf(wes, "VERSION(%s) BUILD(%s) ENV(%s) MHPRA(%d)", [appVersionString UTF8String], [appBuildString UTF8String], env_str, MAX_HOLE_PUNCH_RETRY_ATTEMPTS);
    wlog2(wes, SEVERE_LOG);
    
    [self letsAuthN];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rvc = nil;
    if ([AuthN loggedInLastTimeUserName]) {
        rvc = [storyboard instantiateViewControllerWithIdentifier:@"sbidMainVC"];
    } else {
        rvc = [storyboard instantiateViewControllerWithIdentifier:@"sbidLoginVC"];
    }
    NSArray *controllers = @[rvc];
    
    UINavigationController *nc = (UINavigationController *)self.window.rootViewController;
    [nc setViewControllers:controllers];

    self.contactRequests = [@[] mutableCopy];

    NSNotificationCenter *ndc = [NSNotificationCenter defaultCenter];
    [ndc addObserver:self selector:@selector(handleNewContactRequest:) name:kNotificationAddContactRequest object:nil];
    [ndc addObserver:self selector:@selector(handleContactRequestAccepted:) name:kNotificationContactRequestAccepted object:nil];
    [ndc addObserver:self selector:@selector(handleContactRequestDeclined:) name:kNotificationContactRequestDeclined object:nil];
    [ndc addObserver:self selector:@selector(handleIncomingCall:) name:kNotificationIncomingCall object:nil];
    [ndc addObserver:self selector:@selector(didSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];

    [RTCPeerConnectionFactory initializeSSL];
    
    return YES;
}

- (void)handleNewContactRequest:(NSNotification*)notification {
    NSString *w = [notification.userInfo objectForKey:@"username"];
    if (w && [w isKindOfClass:[NSString class]] && ![w isEqualToString:@""]) {
        [self.contactRequests addObject:[w lowercaseString]];
    }
}

- (void)handleContactRequestAccepted:(NSNotification*)notification {
    NSString *w = [notification.userInfo objectForKey:@"username"];
    if (w && [w isKindOfClass:[NSString class]] && ![w isEqualToString:@""]) {
        [self.contactRequests removeObject:[w lowercaseString]];
    }
}

- (void)handleContactRequestDeclined:(NSNotification*)notification {
    NSString *w = [notification.userInfo objectForKey:@"username"];
    if (w && [w isKindOfClass:[NSString class]] && ![w isEqualToString:@""]) {
        [self.contactRequests removeObject:[w lowercaseString]];
    }
}

- (void)handleIncomingCall:(NSNotification*)notification {
    NSString *serverUrl = [notification.userInfo objectForKey:@"server_host_url"];
    NSString *roomId = [notification.userInfo objectForKey:@"room_id"];
    NSString *fromusername = [notification.userInfo objectForKey:@"fromusername"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        IncomingCallViewController *icvc = [storyboard instantiateViewControllerWithIdentifier:@"sbidIncomingCallVC"];
        icvc.videoUrl = serverUrl;
        icvc.roomId = roomId;
        icvc.fromusername = fromusername;
        UINavigationController *nc = (UINavigationController *)self.window.rootViewController;
        [nc pushViewController:icvc animated:YES];
    });
}

// curtesy of phuongle: http://stackoverflow.com/questions/24595579/how-to-redirect-audio-to-speakers-in-the-apprtc-ios-example
- (void)didSessionRouteChange:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonCategoryChange: {
            // Set speaker as default route
            NSError* error;
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        }
            break;
            
        default:
            break;
    }
}

- (void)letsAuthN {
    NSString *liltun = [AuthN loggedInLastTimeUserName];
    if (!liltun) return;
    NSString *pw = [AuthN getPasswordForUsername:liltun];
    if (!pw) return;
    NODE_USER_STATUS nus = [AuthN loggedInLastTimeUserName] ? NODE_USER_STATUS_EXISTING_USER : NODE_USER_STATUS_UNKNOWN;
    authn(nus, [liltun UTF8String], [pw UTF8String],
          AUTHN_STATUS_RSA_SWAP,
          [AuthN getRSAPubKey],
          [AuthN getRSAPriKey],
          [AuthN getAESKey],
          rsakeypair_generated,
          recd,
          rsa_response,
          aes_key_created,
          aes_response,
          creds_check_result,
          server_connection_failure);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    quit();
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self letsAuthN];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [RTCPeerConnectionFactory deinitializeSSL];
}


@end
