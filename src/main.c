
/*
 * main.c
 *
 * Copyright (c) 2000 Whistle Communications, Inc.
 * All rights reserved.
 * 
 * Subject to the following obligations and disclaimer of warranty, use and
 * redistribution of this software, in source or object code forms, with or
 * without modifications are expressly permitted by Whistle Communications;
 * provided, however, that:
 * 1. Any and all reproductions of the source or object code must include the
 *    copyright notice above and the following disclaimer of warranties; and
 * 2. No rights are granted, in any manner or form, to use Whistle
 *    Communications, Inc. trademarks, including the mark "WHISTLE
 *    COMMUNICATIONS" on advertising, endorsements, or otherwise except as
 *    such appears in the above copyright notice or in the software.
 * 
 * THIS SOFTWARE IS BEING PROVIDED BY WHISTLE COMMUNICATIONS "AS IS", AND
 * TO THE MAXIMUM EXTENT PERMITTED BY LAW, WHISTLE COMMUNICATIONS MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, REGARDING THIS SOFTWARE,
 * INCLUDING WITHOUT LIMITATION, ANY AND ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
 * WHISTLE COMMUNICATIONS DOES NOT WARRANT, GUARANTEE, OR MAKE ANY
 * REPRESENTATIONS REGARDING THE USE OF, OR THE RESULTS OF THE USE OF THIS
 * SOFTWARE IN TERMS OF ITS CORRECTNESS, ACCURACY, RELIABILITY OR OTHERWISE.
 * IN NO EVENT SHALL WHISTLE COMMUNICATIONS BE LIABLE FOR ANY DAMAGES
 * RESULTING FROM OR ARISING OUT OF ANY USE OF THIS SOFTWARE, INCLUDING
 * WITHOUT LIMITATION, ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * PUNITIVE, OR CONSEQUENTIAL DAMAGES, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES, LOSS OF USE, DATA OR PROFITS, HOWEVER CAUSED AND UNDER ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF WHISTLE COMMUNICATIONS IS ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * Author: Archie Cobbs <archie@whistle.com>
 *
 * $FreeBSD$
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <err.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>

#define DEFAULT_PORT	6060

static void	usage(const char *prog) __dead2;

/*
 * main()
 */
int
main(int ac, char *av[])
{
	u_int16_t port = DEFAULT_PORT;
	struct sockaddr_in peer;
	int sock, originate;
	struct hostent *hp;
	const char *prog;
	int verbose = 0;
	int len, suck = 0;
	char buf[1024];
	int rfd, wfd;
	int r, n, w;
	char *s;

	/* Are we 'suck' or 'blow'? */
	if ((prog = strrchr(av[0], '/')) != NULL)
		prog++;
	else
		prog = av[0];
	if (strcmp(prog, "suck") == 0)
		suck = 1;
	else if (strcmp(prog, "blow") != 0)
		errx(EX_USAGE, "unknown program name ``%s''", prog);

	/* Parse command line */
	while ((r = getopt(ac, av, "p:v")) != EOF) {
		switch (r) {
		case 'p':
			if ((port = (u_int16_t)strtoul(optarg, &s, NULL)) == 0
			    || *s != '\0')
				errx(EX_USAGE, "invalid port ``%s''", optarg);
			break;
		case 'v':
			verbose++;
			break;
		case '?':
		default:
			usage(prog);
			break;
		}
	}
	ac -= optind;
	av += optind;

	/* Get remote IP address, if we're going to originate the connection */
	memset(&peer, 0, sizeof(peer));
	peer.sin_len = sizeof(peer);
	peer.sin_family = AF_INET;
	peer.sin_port = htons(port);
	switch (ac) {
	case 0:
		originate = 0;
		break;
	case 1:
		originate = 1;
		if (!inet_aton(av[0], &peer.sin_addr)) {
			if ((hp = gethostbyname(av[0])) == NULL) {
				errx(EX_NOHOST, "cannot resolve %s: %s",
				    av[0], hstrerror(h_errno));
			}
			if (hp->h_length > sizeof(peer.sin_addr))
				errx(1,"gethostbyname: illegal address");
			memcpy(&peer.sin_addr,
			    hp->h_addr_list[0], sizeof(peer.sin_addr));
		}
		break;
	default:
		usage(prog);
	}

	/* Get socket */
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1)
		err(EX_OSERR, "socket");

	/* Connect to peer */
	if (originate) {
		if (connect(sock, (struct sockaddr *)&peer, sizeof(peer)) == -1)
			err(EX_PROTOCOL, "%s", av[0]);
		if (verbose >= 1) {
			warnx("connected to %s:%d",
			    inet_ntoa(peer.sin_addr), (int)port);
		}
	} else {
		static const int un = 1;
		int s2;

		if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &un, sizeof(un)))
			err(EX_OSERR, "setsockopt: SO_REUSEADDR");
		if (bind(sock, (struct sockaddr *)&peer, sizeof(peer)) == -1)
			err(EX_OSERR, "bind");
		if (listen(sock, 1) == -1)
			err(EX_OSERR, "listen");
		len = sizeof(peer);
		if ((s2 = accept(sock, (struct sockaddr *)&peer, &len)) == -1)
			err(EX_OSERR, "accept");
		close(sock);
		sock = s2;
		if (verbose >= 1) {
			warnx("connection from %s:%d",
			    inet_ntoa(peer.sin_addr), ntohs(peer.sin_port));
		}
	}

	/* Transfer data */
	if (suck) {
		rfd = sock;
		wfd = 1;
	} else {
		rfd = 0;
		wfd = sock;
	}
	for (len = 0, r = 1; r > 0; ) {
		switch ((r = read(rfd, buf, sizeof(buf)))) {
		case -1:
			warn("read");
			break;
		case 0:
			close(rfd);
			close(wfd);
			break;
		default:
			for (n = 0; n < r; n += w) {
				if ((w = write(wfd, buf + n, r - n)) == -1) {
					warn("write");
					r = -1;
					break;
				}
				len += w;
			}
			break;
		}
	}
	if (verbose >= 1)
		warnx("transferred %d bytes", len);
	return (r == 0 ? EX_OK : EX_IOERR);
}

/*
 * Print usage and exit
 */
static void usage(const char *prog)
{
	fprintf(stderr, "usage: %s [-p port] [ remote-ip ]\n", prog);
	exit(EX_USAGE);
}

