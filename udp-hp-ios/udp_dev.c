//
//  udp_dev.c
//  udp-hole-punch
//
//  Created by WAYNE SMALL on 2/19/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "udp_dev.h"

char *send_ping() {
    printf("send_ping\n");
    int sock_fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    struct sockaddr_in server;
    server.sin_family = AF_INET;
    server.sin_port = htons(9930);
    inet_pton(AF_INET, "142.105.56.124", &(server.sin_addr));
    size_t r = sendto(sock_fd, "sup yo dawg", 11, 0, (struct sockaddr*)(&server), sizeof(server));
    if (r == -1) return "There was a problem send_ping::sendto";
    return "send_ping::sendto was sent";
}
