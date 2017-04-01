//
//  UdpClientCallbacks.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/31/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "UdpClientCallbacks.h"
#import "AuthN.h"
#import "ViewController.h"
#import "ObjcContact.h"

UITextView *wlogger;

void register_for_wlog(UITextView *tv) {
    wlogger = tv;
}

void wlog(NSString *w) {
//    if (!vcs) {
//        NSLog(@"VC-singleton not found");
//        return;
//    }
//    
//    if (!vcs.daConsole) {
//        NSLog(@"daText not found");
//        return;
//    }
    
    if (!wlogger) {
        NSLog(@"NO REGISTERED wlogger");
        return;
    }
    
    //    unichar last = [vcs.daConsole.text characterAtIndex:([vcs.daConsole.text length] - 1)];
    NSString *s = /*last == '\n' ? @"" :*/ @"\n";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wlogger setText:[NSString stringWithFormat:@"%@%@%@", vcs.daConsole.text, s, w]];
        NSRange bottom = NSMakeRange(vcs.daConsole.text.length - 1, 1);
        [wlogger scrollRangeToVisible:bottom];
    });
    
}

void rsakeypair_generated(const char *rsa_pub_key, const char *rsa_pri_key) {
    
}

void rsa_response(char *server_rsa_key) {
    char w[640];
    sprintf(w, "server's public key (%s)\n", server_rsa_key);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void aes_key_created(unsigned char *aes_key) {
    [AuthN setAESKey:[NSData dataWithBytes:aes_key length:NUM_BYTES_AES_KEY]];
    char w[640];
    sprintf(w, "AES key created (%s)(%lu)\n", [AuthN getAESKey], [AuthN getSizeOfAESKey]);
    printf("%s\n", w);
    wlog([NSString stringWithUTF8String:w]);
}

void creds_check_result(AUTHN_CREDS_CHECK_RESULT cr, char *username,
                        char *password, unsigned char *authn_token) {
    if (cr == AUTHN_CREDS_CHECK_RESULT_GOOD) {
        [AuthN addUsername:[NSString stringWithUTF8String:username]
               andPassword:[NSString stringWithUTF8String:password]];
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
    char w[256];
    sprintf(w, "creds_check_result (%s)", creds_check_result_to_str(cr));
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

@implementation UdpClientCallbacks

@end
