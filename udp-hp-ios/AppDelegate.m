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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewContactRequest:) name:kNotificationAddContactRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContactRequestAccepted:) name:kNotificationContactRequestAccepted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContactRequestDeclined:) name:kNotificationContactRequestDeclined object:nil];
    
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

- (void)letsAuthN {
    NODE_USER_STATUS nus = [AuthN loggedInLastTimeUserName] ? NODE_USER_STATUS_EXISTING_USER : NODE_USER_STATUS_UNKNOWN;
    authn(nus,
          [[AuthN loggedInLastTimeUserName] UTF8String],
          [[AuthN getPasswordForUsername:[AuthN loggedInLastTimeUserName]] UTF8String],
          AUTHN_STATUS_RSA_SWAP,
          [AuthN getRSAPubKey],
          [AuthN getRSAPriKey],
          [AuthN getAESKey],
          rsakeypair_generated,
          recd,
          rsa_response,
          aes_key_created,
          creds_check_result);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    quit();
}


@end
