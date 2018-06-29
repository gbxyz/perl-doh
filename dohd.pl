#!/usr/bin/perl
# Simple DNS-over-HTTPS server. Copyright 2018 CentralNic Ltd
use File::Basename qw(basename);
use Getopt::Long;
use HTTP::Daemon;
use List::MoreUtils qw(any);
use MIME::Base64;
use Net::DNS;
use POSIX qw(setsid);
use Sys::Syslog qw(:standard :macros);
use URI;
use strict;

my @types = qw(application/dns-message application/dns-udpwireformat);

my $addr  = '127.0.0.1';
my $port  = '8080';
my $raddr = '127.0.0.1';
my $daemon = undef;
GetOptions(
	'addr=s'	=> \$addr,
	'port=i'	=> \$port,
	'resolver=s'	=> \$raddr,
	'debug'		=> \$HTTP::Daemon::DEBUG,
	'daemon'	=> \$daemon,
);

my $resolver = Net::DNS::Resolver->new(
	'nameservers'		=> [ $raddr ],
	'debug'			=> $HTTP::Daemon::DEBUG,
	'persistent_tcp'	=> 1,
	'tcp_timeout'		=> 1,
	'udp_timeout'		=> 1,
	'retry'			=> 1,
);

openlog(basename(__FILE__, '.pl'), 'pid,perror', LOG_DAEMON);
setlogmask(LOG_UPTO(LOG_DEBUG));

my $server = HTTP::Daemon->new(
	'LocalAddr'	=> $addr,
	'LocalPort'	=> $port,
);

if (!$server) {
	chomp($@);
	syslog(LOG_CRIT, sprintf('Unable to start server on %s:%u: %s', $addr, $port, $@));
	exit(1);

} else {
	syslog(LOG_INFO, sprintf('DoH server running on %s', $server->url));

}

if ($daemon) {
	syslog(LOG_DEBUG, 'daemonizing');
	if (fork() > 0) {
		exit 0;

	} else {
		setsid();
		chdir('/');
		$0 = sprintf('[%s]', basename(__FILE__));

	}
}

#
# listen for connections
#
while (my $connection = $server->accept) {

	#
	# catch errors by using eval { ... }
	#
	eval {
		handle_connection($connection);
		$connection->close;
		undef($connection);
	};

	if ($@) {
		chomp($@);
		syslog(LOG_DEBUG, sprintf('%s: %s', $connection->peerhost, $@));
	}
}

#
# handle a connection
#
sub handle_connection {

	#
	# $connection is a HTTPP:Daemon::ClientConn
	#
	my $connection = shift;

	#
	# $request is a HTTP::Request
	#
	my $request = $connection->get_request;

	if (!$request) {
		syslog(LOG_DEBUG, sprintf('%s 400 (%s)', $connection->peerhost, $connection->reason));
		$connection->send_error(400);

	} else {

		#
		# DNS query packet data goes here
		#
		my $data;

		if ($request->method eq 'GET') {

			#
			# extract packet data from query string
			#
			my %params = URI->new_abs($request->uri, $server->url)->query_form;

			$data = decode_base64($params{'dns'} || $params{'body'});

		} elsif ($request->method eq 'POST') {
			if (!any { lc($_) eq lc($request->header('Content-Type')) } @types) {
				syslog(LOG_DEBUG, sprintf("%s 415 (type is '%s')", $connection->peerhost, $request->header('Content-Type')));
				$connection->send_error(415);
				return undef;

			} else {
				$data = $request->content;

			}

		} else {
			syslog(LOG_DEBUG, sprintf("%s 405 (method is '%s')", $connection->peerhost, $request->method));
			$connection->send_error(405);
			return undef;

		}

		#
		# build packet object from data
		#
		my $packet = Net::DNS::Packet->new(\$data);

		if (!$packet) {
			syslog(LOG_DEBUG, sprintf('%s 400 (unable to parse packet data)', $connection->peerhost));
			$connection->send_error(400);

		} else {
			#
			# send the packet to the server
			#
			my $response = $resolver->send($packet);

			if (!$response) {
				syslog(LOG_DEBUG, sprintf('%s 504 (%s)', $connection->peerhost, $resolver->errorstring));
				$connection->send_error(504);

			} else {
				syslog(LOG_DEBUG, sprintf('%s %s/%s/%s %s', $connection->peerhost, ($response->question)[0]->qname, ($response->question)[0]->qclass, ($response->question)[0]->qtype, lc($response->header->rcode)));

				#
				# send the response back to the client
				#
				$connection->send_status_line;
				$connection->send_header('Server', basename(__FILE__, '.pl'));
				$connection->send_header('Content-Type', $types[0]);
				$connection->send_header('Connection', 'close');
				$connection->send_crlf;
				$connection->print($response->data);

			}
		}
	}
}
