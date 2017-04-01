//
//  UdpClientCallbacks.h
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/31/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "udp_client.h"

void register_for_wlog(UITextView *tv);

void wlog(NSString *w);

void rsakeypair_generated(const char *rsa_pub_key, const char *rsa_pri_key);

void rsa_response(char *server_rsa_key);

void aes_key_created(unsigned char *aes_key);

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

void new_peer(char *w);

void hole_punch_sent(char *w, int t);

void confirmed_peer_while_punching(SERVER_TYPE st);

void from_peer(SERVER_TYPE st, char *w);

void chat_msg(char *w);

void unhandled_response_from_server(int w);

void whilew(int w);

void end_while(void);

@interface UdpClientCallbacks : NSObject

@end
