//
//  ViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 2/26/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ViewController.h"
#import "udp_dev.h"
#import "udp_client.h"
#import "ObjcContact.h"
#import "ListContactsViewController.h"
#include "WESKeyChain.h"
#include "crypto_wrapper.h"

char *rsa_public_kee;
char *rsa_private_kee;
unsigned char *aes_kee;

NSString * const kKeyRSAPublicKey = @"kKeyRSAPublicKey";
NSString * const kKeyRSAPrivateKey = @"kKeyRSAPrivateKey";
NSString * const kKeyAESKey = @"kKeyAESKey";

static ViewController *vcs;

void wlog(NSString *w) {
    if (!vcs) {
        NSLog(@"VC-singleton not found");
        return;
    }
    
    if (!vcs.daConsole) {
        NSLog(@"daText not found");
        return;
    }
    
//    unichar last = [vcs.daConsole.text characterAtIndex:([vcs.daConsole.text length] - 1)];
    NSString *s = /*last == '\n' ? @"" :*/ @"\n";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [vcs.daConsole setText:[NSString stringWithFormat:@"%@%@%@", vcs.daConsole.text, s, w]];
        NSRange bottom = NSMakeRange(vcs.daConsole.text.length - 1, 1);
        [vcs.daConsole scrollRangeToVisible:bottom];
    });
    
}

void rsa_response(char *server_rsa_key) {
    char w[640];
    sprintf(w, "server's public key (%s)\n", server_rsa_key);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void aes_key_created(unsigned char *aes_key) {
    aes_kee = aes_key;
    [WESKeyChain setObject:[NSData dataWithBytes:aes_kee length:NUM_BYTES_AES_KEY] forKey:kKeyAESKey];
    char w[640];
    sprintf(w, "AES key created (%s)(%lu)\n", aes_kee, sizeof(aes_key));
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void self_info(char *w, unsigned short port, unsigned short chat_port, unsigned short family) {
    char e[256];
    sprintf(e, "self: %s p:%d cp:%d f:%d", w, port, chat_port, family);
    printf("%s\n", e);
    wlog([NSString stringWithUTF8String:e]);
}

void server_info(SERVER_TYPE st, char *w) {
    char e[256];
    sprintf(e, "server_info (%s) (%s)", str_from_server_type(st), w);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void socket_created(int sock_fd) {
    char w[256];
    sprintf(w, "The socket file descriptor is %d", sock_fd);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void socket_bound(void) {
    char *w = "The socket was bound";
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void sendto_succeeded(size_t bytes_sent) {
    char w[256];
    sprintf(w, "sendto succeeded, %zu bytes sent", bytes_sent);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void recd(SERVER_TYPE st, size_t bytes_recd, socklen_t addr_len, char *w) {
    char e[256];
    sprintf(e, "recvfrom %s %zu %u %s", str_from_server_type(st), bytes_recd, addr_len, w);
    printf("%s\n", e);
    wlog([NSString stringWithUTF8String:e]);
}

void coll_buf(char *w) {
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void new_client(SERVER_TYPE st, char *w) {
    char *st_str = str_from_server_type(st);
    char e[256];
    sprintf(e, "new_client %s %s", st_str, w);
    printf("%s\n", e);
    wlog([NSString stringWithUTF8String:e]);
}

void notify_existing_contact(char *w) {
    char e[256];
    sprintf(e, "EXISTING_CONTACT:%s", w);
    printf("%s\n", e);
    wlog([NSString stringWithUTF8String:e]);
    
    contact_list_t *contacts;
    list_contacts(&contacts);
    if (!contacts) {
        wlog(@"NO CONTACTS");
        return;
    }
    contact_t *c = contacts->head;
    vcs.arrContacts = [@[] mutableCopy];
    while (c) {
        ObjcContact *oc = [ObjcContact new];
        oc.theContact = c;
        [vcs.arrContacts addObject:oc];
        c = c->next;
    }
}

void stay_touch_recd(SERVER_TYPE st) {
    char *st_str = str_from_server_type(st);
    char w[256];
    sprintf(w, "stay_touch_recd %s", st_str);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void confirmed_client() {
    char *w = "Confirmed client";
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void new_peer(char *w) {
    printf("%s", w);
    wlog([NSString stringWithUTF8String:w]);
}

void hole_punch_sent(char *w, int t) {
    char wc [256];
    sprintf(wc, "%s count %d", w, t);
    printf("%s\n", wc);
    wlog([NSString stringWithUTF8String:wc]);
}

void confirmed_peer_while_punching(SERVER_TYPE st) {
    char w[256];
    switch (st) {
        case SERVER_MAIN: {
            strcpy(w, "*$*$*$*$*$*$*$*$*$*$*$*$*");
            break;
        }
        case SERVER_CHAT: {
            strcpy(w, "@-@-@-@-@-@-@-@-@-@-@-@-@");
            break;
        }
        default:
            break;
    }
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void from_peer(SERVER_TYPE st, char *w) {
    char *st_str = str_from_server_type(st);
    char e[256];
    sprintf(e, "from_peer %s %s", st_str, w);
    printf("%s\n", e);
    wlog([NSString stringWithUTF8String:e]);
}

void chat_msg(char *w) {
    char e[256];
    sprintf(e, "$#$#$#$#$#$# %s", w);
    printf("%s\n", e);
    wlog([NSString stringWithUTF8String:e]);
}

void unhandled_response_from_server(int w) {
    char wc [100];
    sprintf(wc, "unhandled_response_from_server::%d", w);
    printf("%s", wc);
    wlog([NSString stringWithUTF8String:wc]);
}

void whilew(int w) {
    char wt[256];
    sprintf(wt, "Meanwhile...%d\n", w);
    printf("%s", wt);
    wlog([NSString stringWithUTF8String:wt]);
}

void end_while(void) {
    char *w = "Ending while looping***************\n";
    printf("%s", w);
    wlog([NSString stringWithUTF8String:w]);
}

@interface ViewController () <UITextViewDelegate>

@end

@implementation ViewController

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [textView resignFirstResponder];
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    vcs = self;
    self.daConsole.delegate = self;
    self.arrContacts = [@[] mutableCopy];
    
    [self amiExistingUserOnThisDevice];
    [self letsAuthN];
}

- (void)letsAuthN {
    authn(AUTHN_STATUS_RSA_SWAP,
          rsa_public_kee,
          rsa_private_kee,
          aes_kee,
          recd,
          rsa_response,
          aes_key_created);
}

- (BOOL)amiExistingUserOnThisDevice {
    NSString *rsaPubKey = [WESKeyChain objectForKey:kKeyRSAPublicKey];
    NSString *rsaPriKey = [WESKeyChain objectForKey:kKeyRSAPrivateKey];
    NSData *aesKey = [WESKeyChain objectForKey:kKeyAESKey];
    if (aesKey) {
        aes_kee = malloc(NUM_BYTES_AES_KEY);
        memset(aes_kee, '\0', NUM_BYTES_AES_KEY);
        aes_kee = (unsigned char *)[aesKey bytes];
    }
    if (rsaPubKey && rsaPriKey) {
        size_t pub_sz = strlen([rsaPubKey UTF8String]);
        size_t pri_sz = strlen([rsaPriKey UTF8String]);
        rsa_public_kee = malloc(pub_sz);
        rsa_private_kee = malloc(pri_sz);
        memset(rsa_public_kee, '\0', pub_sz);
        memset(rsa_private_kee, '\0', pri_sz);
        strcpy(rsa_public_kee, [rsaPubKey UTF8String]);
        strcpy(rsa_private_kee, [rsaPriKey UTF8String]);
        return YES;
    } else {
        char *rsa_pub_key = NULL;
        char *rsa_pri_key = NULL;
        generate_rsa_keypair(NULL, &rsa_pri_key, &rsa_pub_key, NULL, NULL);
        if (!rsa_pub_key || !rsa_pri_key) {
            // TODO handle this: probably show a message and terminate app
            return NO;
        }
        size_t pub_sz = strlen(rsa_pub_key);
        size_t pri_sz = strlen(rsa_pri_key);
        rsa_public_kee = malloc(pub_sz);
        rsa_private_kee = malloc(pri_sz);
        memset(rsa_public_kee, '\0', pub_sz);
        memset(rsa_private_kee, '\0', pri_sz);
        strcpy(rsa_public_kee, rsa_pub_key);
        strcpy(rsa_private_kee, rsa_pri_key);
        [WESKeyChain setObject:[NSString stringWithUTF8String:rsa_private_kee] forKey:kKeyRSAPrivateKey];
        [WESKeyChain setObject:[NSString stringWithUTF8String:rsa_public_kee] forKey:kKeyRSAPublicKey];
    }
    return NO;
}

- (IBAction)tapPing:(id)sender {
    printf("tapPing\n");
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    char *w = send_ping();
    wlog([NSString stringWithUTF8String:w]);
}

- (IBAction)tapHolePunch:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapHolePunch");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        wain(self_info,
             socket_created,
             socket_bound,
             sendto_succeeded,
             coll_buf,
             new_client,
             confirmed_client,
             notify_existing_contact,
             stay_touch_recd,
             new_peer,
             hole_punch_sent,
             confirmed_peer_while_punching,
             from_peer,
             chat_msg,
             unhandled_response_from_server,
             whilew,
             end_while);
    });
}

- (IBAction)tapPingAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapPingAllPeers");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ping_all_peers();
    });
}

- (IBAction)tapSendMessageAllPeers:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapPingAllPeers");
    char w[32];
    strcpy(w, "hi-de-ho neighbor");
    send_message_to_all_peers(w);
}

- (IBAction)tapListContacts:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor purpleColor];
    wlog(@"tapListContacts");
    for (ObjcContact *oc in self.arrContacts) {
        wlog([NSString stringWithFormat:@"Da Contact is %@", [oc username]]);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSegueListContacts"]) {
        ListContactsViewController *lcvc = segue.destinationViewController;
        lcvc.contacts = self.arrContacts;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
