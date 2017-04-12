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
#import "Shared.h"
#import <AudioToolbox/AudioToolbox.h>

@interface WlogDelegate : NSObject
@property (nonatomic) wlogCallback callback;
@end

@implementation WlogDelegate
@end

NSMutableArray<WlogDelegate *> *delegates;
NSString *wLogs = @"";
NSMutableArray<ObjcContact*> *arrContacts;

NSString *addWlogCallback(wlogCallback callback) {
    if (!delegates) delegates = [@[] mutableCopy];
    WlogDelegate *wld = [WlogDelegate new];
    wld.callback = callback;
    [delegates addObject:wld];
    return wLogs;
}

void wlog2(char *log) {
    char w[512] = {0};
    sprintf(w, "%s\n", log);
    printf("%s", w);
    NSString *newLog = [NSString stringWithUTF8String:w];
    wLogs = [wLogs stringByAppendingString:newLog];
    for (WlogDelegate *d in delegates)
        if (d.callback) d.callback(newLog, wLogs);
}

void rsakeypair_generated(const char *rsa_pub_key, const char *rsa_pri_key) {
    
}

void rsa_response(char *server_rsa_key) {
    char w[640];
    sprintf(w, "server's public key (%s)", server_rsa_key);
    wlog2(w);
}

void aes_key_created(unsigned char *aes_key) {
    [AuthN setAESKey:[NSData dataWithBytes:aes_key length:NUM_BYTES_AES_KEY]];
    char w[640];
    sprintf(w, "AES key created (%s)(%lu)", [AuthN getAESKey], [AuthN getSizeOfAESKey]);
    wlog2(w);
}

void creds_check_result(AUTHN_CREDS_CHECK_RESULT cr, char *username,
                        char *password, unsigned char *authn_token) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCredentialsCheckResult object:[NSNumber numberWithInt:cr]];
    switch (cr) {
        case AUTHN_CREDS_CHECK_RESULT_GOOD: {
            [AuthN addUsername:[NSString stringWithUTF8String:username]
                   andPassword:[NSString stringWithUTF8String:password]];
            [AuthN setLoggedInLastTimeUserName:[NSString stringWithUTF8String:username]];
            wain(self_info,
                 server_info,
                 socket_created,
                 socket_bound,
                 sendto_succeeded,
                 coll_buf,
                 new_client,
                 confirmed_client,
                 notify_existing_contact,
                 stay_touch_recd,
                 add_contact_request,
                 contact_request_accepted,
                 contact_request_declined,
                 new_peer,
                 hole_punch_sent,
                 confirmed_peer_while_punching,
                 from_peer,
                 chat_msg,
                 unhandled_response_from_server,
                 whilew,
                 end_while);
            break;
        }
        case AUTHN_CREDS_CHECK_RESULT_USER_NOT_FOUND: {
            // TODO
            break;
        }
        case AUTHN_CREDS_CHECK_RESULT_WRONG_PASSWORD: {
            // TODO
            break;
        }
        case AUTHN_CREDS_CHECK_RESULT_MISC_ERROR: {
            // TODO
            break;
        }
        default: {
            // TODO
            break;
        }
    }
    char w[256];
    sprintf(w, "creds_check_result (%s)", creds_check_result_to_str(cr));
    wlog2(w);
}

void self_info(char *w, unsigned short port, unsigned short chat_port, unsigned short family) {
    char e[256];
    sprintf(e, "self: %s p:%d cp:%d f:%d", w, port, chat_port, family);
    wlog2(e);
}

void server_info(SERVER_TYPE st, char *w) {
    char e[256];
    sprintf(e, "server_info (%s) (%s)", str_from_server_type(st), w);
    wlog2(e);
}

void socket_created(int sock_fd) {
    char w[256];
    sprintf(w, "The socket file descriptor is %d", sock_fd);
    wlog2(w);
}

void socket_bound(void) {
    char *w = "The socket was bound";
    wlog2(w);
}

void sendto_succeeded(size_t bytes_sent) {
    char w[256];
    sprintf(w, "sendto succeeded, %zu bytes sent", bytes_sent);
    wlog2(w);
}

void recd(SERVER_TYPE st, size_t bytes_recd, socklen_t addr_len, char *w) {
    char e[256] = {0};
    sprintf(e, "recvfrom %s %zu %u %s", str_from_server_type(st), bytes_recd, addr_len, w);
    wlog2(e);
}

void coll_buf(char *w) {
    wlog2(w);
}

void new_client(SERVER_TYPE st, char *w) {
    char *st_str = str_from_server_type(st);
    char e[256];
    sprintf(e, "new_client %s %s", st_str, w);
    wlog2(e);
}

void notify_existing_contact(char *w) {
    char e[256];
    sprintf(e, "EXISTING_CONTACT:%s", w);
    wlog2(e);
    
    contact_list_t *contacts;
    list_contacts(&contacts);
    if (!contacts) {
        wlog2("NO CONTACTS");
        return;
    }
    contact_t *c = contacts->head;
    // TODO redo this - we shouldn't have to reset
    // arrContacts everytime
    arrContacts = [@[] mutableCopy];
    while (c) {
        ObjcContact *oc = [ObjcContact new];
        oc.theContact = c;
        [arrContacts addObject:oc];
        c = c->next;
    }
}

void stay_touch_recd(SERVER_TYPE st) {
    char *st_str = str_from_server_type(st);
    char w[256];
    sprintf(w, "stay_touch_recd %s", st_str);
    wlog2(w);
}

void confirmed_client() {
    char *w = "Confirmed client";
    wlog2(w);
}

void add_contact_request(char *username) {
    AudioServicesPlaySystemSound(1012);
    NSDictionary *d = @{@"username":[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddContactRequest object:nil userInfo:d];
    char w[256];
    sprintf(w, "add_contact_request from %s", username);
    wlog2(w);
}

void contact_request_accepted(char *username) {
    AudioServicesPlaySystemSound(1022);
    NSDictionary *d = @{@"username":[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactRequestAccepted object:nil userInfo:d];
    char w[256];
    sprintf(w, "contact_request_accepted from %s", username);
    wlog2(w);
}

void contact_request_declined(char *username) {
    NSDictionary *d = @{@"username":[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactRequestDeclined object:nil userInfo:d];
    char w[256];
    sprintf(w, "contact_request_declined from %s", username);
    wlog2(w);
}

void new_peer(char *w) {
    wlog2(w);
}

void hole_punch_sent(char *w, int t) {
    char wc [256];
    sprintf(wc, "%s count %d", w, t);
    wlog2(wc);
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
    wlog2(w);
}

void from_peer(SERVER_TYPE st, char *w) {
    char *st_str = str_from_server_type(st);
    char e[256];
    sprintf(e, "from_peer %s %s", st_str, w);
    wlog2(e);
}

void chat_msg(char *w) {
    char e[256];
    sprintf(e, "$#$#$#$#$#$# %s", w);
    wlog2(e);
}

void unhandled_response_from_server(int w) {
    char wc [100];
    sprintf(wc, "unhandled_response_from_server::%d", w);
    wlog2(wc);
}

void whilew(int w) {
    char wt[256];
    sprintf(wt, "Meanwhile...%d\n", w);
    wlog2(wt);
}

void end_while(void) {
    char *w = "Ending while looping***************\n";
    wlog2(w);
}

@implementation UdpClientCallbacks

@end
