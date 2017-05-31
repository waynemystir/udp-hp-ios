//
//  UdpClientCallbacks.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/31/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "udp_client.h"

void init_app_settings();

extern NSMutableArray *arrContacts;

typedef void(*wlogCallback)(NSString *newStr, NSString *allLogs, LOG_LEVEL log_level);

NSString *addWlogCallback(wlogCallback);

void wlog2(char *log, LOG_LEVEL log_level);

void pfail_bc(char *err_msg);

void connectivity(IF_ADDR_PREFFERED, int);

void rsakeypair_generated(const char *rsa_pub_key, const char *rsa_pri_key);

void rsa_response(char *server_rsa_key);

void aes_key_created(unsigned char *aes_key);

void aes_response(NODE_USER_STATUS nus);

void creds_check_result(AUTHN_CREDS_CHECK_RESULT cr, char *username,
                        char *password, unsigned char *authn_token);

void self_info(char *w, unsigned short port, unsigned short chat_port, unsigned short family);

void server_info(SERVER_TYPE st, char *w);

void socket_created(int sock_fd);

void socket_bound(void);

void sendto_succeeded(size_t bytes_sent);

void recd(SERVER_TYPE st, size_t bytes_recd, socklen_t addr_len, char *w);

void coll_buf(char *w);

void new_client(SERVER_TYPE st, char *w);

void notify_existing_contact(char *w);

void stay_touch_recd(SERVER_TYPE st);

void confirmed_client();

void contact_deinit_node(char *contactname);

void add_contact_request(char *username);

void contact_request_accepted(char *username);

void contact_request_declined(char *username);

void new_peer(char *w);

void proceed_chat_hp(char *);

void hole_punch_thrd(char *w);

void hole_punch_sent_p1(char *w, int t);

void hole_punch_sent(char *w, int t);

void confirmed_peer_while_punching(SERVER_TYPE st);

void from_peer(SERVER_TYPE st, char *w);

void chat_msg(char *username, char *msg);

void video_start(char *server_host_url, char *room_id, char *fromusername);

void unhandled_response_from_server(int w);

void server_connection_failure(SERVER_TYPE, char*);

void general(char *w, LOG_LEVEL);

@interface UdpClientCallbacks : NSObject

@end
