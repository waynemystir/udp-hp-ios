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
#import <pthread.h>

static pthread_once_t env_once = PTHREAD_ONCE_INIT;
static ENVIRONMENT environment;
static pthread_once_t mutexes_once = PTHREAD_ONCE_INIT;
static pthread_mutex_t wLogsLock;
int tErr;

void init_local_environment() {
    environment = PROD;
}

void init_mutexes() {
    tErr = pthread_mutex_init(&wLogsLock, NULL);
}

void init_environment() {
    pthread_once(&env_once, init_local_environment);
    pthread_once(&mutexes_once, init_mutexes);
}

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

void wlog2(char *log, LOG_LEVEL log_level) {
    pthread_mutex_lock(&wLogsLock);
    char w[512] = {0};
    sprintf(w, "%s\n", log);
    printf("%s", w);
    if (log_level < INFO_LOG && environment == PROD) {
        pthread_mutex_unlock(&wLogsLock);
        return;
    }

    NSString *newLog = [NSString stringWithUTF8String:w];
    wLogs = [wLogs stringByAppendingString:newLog];
    for (WlogDelegate *d in delegates)
        if (d.callback) d.callback(newLog, wLogs, log_level);
    pthread_mutex_unlock(&wLogsLock);
}

void pfail_bc(char *err_msg) {
    char w[256];
    sprintf(w, "PFFFFFFFFFFFFAILLLLLLLLL (%s)", err_msg);
    wlog2(w, SEVERE_LOG);
}

void rsakeypair_generated(const char *rsa_pub_key, const char *rsa_pri_key) {
    
}

void rsa_response(char *server_rsa_key) {
    char w[640];
    sprintf(w, "server's public key strlen (%lu)", strlen(server_rsa_key));
    wlog2(w, INFO_LOG);
}

void aes_key_created(unsigned char *aes_key) {
    [AuthN setAESKey:[NSData dataWithBytes:aes_key length:NUM_BYTES_AES_KEY]];
    char w[640];
    sprintf(w, "AES key created (%s)(%lu)", [AuthN getAESKey], [AuthN getSizeOfAESKey]);
    wlog2(w, INFO_LOG);
}

void aes_response(NODE_USER_STATUS nus) {
    char w[256];
    sprintf(w, "aes_response (%s)", node_user_status_to_str(nus));
    wlog2(w, INFO_LOG);
    
    NODE_USER_STATUS nusf = [AuthN loggedInLastTimeUserName] ? NODE_USER_STATUS_EXISTING_USER : NODE_USER_STATUS_UNKNOWN;
    char *username = (char*)[[AuthN loggedInLastTimeUserName] UTF8String];
    char *password = (char*)[[AuthN getPasswordForUsername:[AuthN loggedInLastTimeUserName]] UTF8String];
    if (username && password) send_user(nusf, username, password);
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
                 contact_deinit_node,
                 add_contact_request,
                 contact_request_accepted,
                 contact_request_declined,
                 new_peer,
                 proceed_chat_hp,
                 hole_punch_sent,
                 confirmed_peer_while_punching,
                 from_peer,
                 chat_msg,
                 video_start,
                 unhandled_response_from_server);
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
    wlog2(w, INFO_LOG);
}

void self_info(char *w, unsigned short port, unsigned short chat_port, unsigned short family) {
    char e[256];
    sprintf(e, "self: %s p:%d cp:%d f:%d", w, port, chat_port, family);
    wlog2(e, INFO_LOG);
}

void server_info(SERVER_TYPE st, char *w) {
    char e[256];
    sprintf(e, "server_info (%s) (%s)", str_from_server_type(st), w);
    wlog2(e, INFO_LOG);
}

void socket_created(int sock_fd) {
    char w[256];
    sprintf(w, "The socket file descriptor is %d", sock_fd);
    wlog2(w, INFO_LOG);
}

void socket_bound(void) {
    char *w = "The socket was bound";
    wlog2(w, INFO_LOG);
}

void sendto_succeeded(size_t bytes_sent) {
    char w[256];
    sprintf(w, "sendto succeeded, %zu bytes sent", bytes_sent);
    wlog2(w, INFO_LOG);
}

void recd(SERVER_TYPE st, size_t bytes_recd, socklen_t addr_len, char *w) {
    char e[256] = {0};
    sprintf(e, "recvfrom %s %zu %u %s", str_from_server_type(st), bytes_recd, addr_len, w);
    wlog2(e, INFO_LOG);
}

void coll_buf(char *w) {
    wlog2(w, INFO_LOG);
}

void new_client(SERVER_TYPE st, char *w) {
    char *st_str = str_from_server_type(st);
    char e[256];
    sprintf(e, "new_client %s %s", st_str, w);
    wlog2(e, INFO_LOG);
}

void notify_existing_contact(char *w) {
    char e[256];
    sprintf(e, "EXISTING_CONTACT:%s", w);
    wlog2(e, INFO_LOG);
    
    contact_list_t *contacts;
    list_contacts(&contacts);
    if (!contacts) {
        wlog2("NO CONTACTS", INFO_LOG);
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
    wlog2(w, INFO_LOG);
}

void confirmed_client() {
    char *w = "Confirmed client";
    wlog2(w, INFO_LOG);
}

void contact_deinit_node(char *contactname) {
    char e[256];
    sprintf(e, "DEINIT_CONTACT_NODE:%s", contactname);
    wlog2(e, INFO_LOG);
    
    contact_list_t *contacts;
    list_contacts(&contacts);
    contact_t *c = contacts->head;
    while (c) {
        if (0 == strcmp(contactname, c->hn->username)) {
            char e[256];
            sprintf(e, "DEINIT_CONTACT_NODE_222:(%s)(%d)", contactname, c->hn->nodes->node_count);
            wlog2(e, INFO_LOG);
        }
        c = c->next;
    }
}

void add_contact_request(char *username) {
    AudioServicesPlaySystemSound(1012);
    NSDictionary *d = @{@"username":[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddContactRequest object:nil userInfo:d];
    char w[256];
    sprintf(w, "add_contact_request from %s", username);
    wlog2(w, INFO_LOG);
}

void contact_request_accepted(char *username) {
    AudioServicesPlaySystemSound(1022);
    NSDictionary *d = @{@"username":[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactRequestAccepted object:nil userInfo:d];
    char w[256];
    sprintf(w, "contact_request_accepted from %s", username);
    wlog2(w, INFO_LOG);
}

void contact_request_declined(char *username) {
    NSDictionary *d = @{@"username":[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactRequestDeclined object:nil userInfo:d];
    char w[256];
    sprintf(w, "contact_request_declined from %s", username);
    wlog2(w, INFO_LOG);
}

void new_peer(char *w) {
    wlog2(w, INFO_LOG);
}

void proceed_chat_hp(char *w) {
    wlog2(w, INFO_LOG);
}

void hole_punch_sent(char *w, int t) {
    char wc [256];
    sprintf(wc, "%s count %d", w, t);
    wlog2(wc, DEBUG_LOG);
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
    wlog2(w, SEVERE_LOG);
}

void from_peer(SERVER_TYPE st, char *w) {
    char *st_str = str_from_server_type(st);
    char e[256];
    sprintf(e, "from_peer %s %s", st_str, w);
    wlog2(e, INFO_LOG);
}

void chat_msg(char *username, char *msg) {
    NSDictionary *d = @{
                        @"username":[NSString stringWithUTF8String:username],
                        @"msg":[NSString stringWithUTF8String:msg]
                        };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatMsgRecd object:nil userInfo:d];
    char e[256];
    sprintf(e, "$#$#$#$#$#$# (%s):(%s)", username, msg);
    wlog2(e, INFO_LOG);
}

void video_start(char *server_host_url, char *room_id) {
    NSDictionary *d = @{
                        @"server_host_url":[NSString stringWithUTF8String:server_host_url],
                        @"room_id":[NSString stringWithUTF8String:room_id]
                        };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIncomingCall object:nil userInfo:d];
    char w[256];
    sprintf(w, "video_startVVVVVVVVVVVVVVVVVVVV (%s)(%s)", server_host_url, room_id);
    wlog2(w, INFO_LOG);
}

void unhandled_response_from_server(int w) {
    char wc [100];
    sprintf(wc, "unhandled_response_from_server::%d", w);
    wlog2(wc, INFO_LOG);
}

void general(char *w) {
    char wt[256];
    sprintf(wt, "GENERAL (%s)", w);
    wlog2(wt, INFO_LOG);
}

@implementation UdpClientCallbacks

@end
