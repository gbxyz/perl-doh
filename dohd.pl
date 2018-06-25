#!/usr/bin/perl
# Simple DNS-over-HTTPS server. Copyright 2018 CentralNic Ltd
use Getopt::Long;
use HTTP::Daemon;
use Net::DNS;
use Net::IP;
use MIME::Base64;
use URI;
use strict;

my $ct = 'application/dns-message';
my $laddr = '127.0.0.1';
my $lport = '8080';
my $raddr = '1.1.1.1';

my $resolver = Net::DNS::Resolver->new('nameservers' => [ $raddr ]);

my $server = HTTP::Daemon->new(
	'LocalAddr' => $laddr,
	'LocalPort' => $lport,
);

if (!$server) {
	printf(STDERR "Unable to start server on %s:%u: %s\n", $laddr, $lport, $@);
	exit(1);
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

	#
	# DNS query packet data goes here
	#
	my $data;

	if ($request->method eq 'GET') {

		#
		# extract packet data from query string
		#
		my %params = URI->new_abs($request->uri, $server->url)->query_form;

		$data = decode_base64($params{'dns'});

	} elsif ($request->method eq 'POST') {
		if ($ct ne $request->header('Content-Type')) {
			$connection->send_error(415);

		} else {
			$data = $request->content;

		}

	} else {
		$connection->send_error(405);
		return;

	}

	my $packet = Net::DNS::Packet->new(\$data);

	if (!$packet) {
		$connection->send_error(400);
		return;

	} else {
		#
		# send the packet to the server
		#
		my $response = $resolver->send($packet);

		if (!$response) {
			$connection->send_error(504);

		} else {
			#
			# send the response back to the client
			#
			$connection->send_status_line;
			$connection->send_header('Content-Type', $ct);
			$connection->send_header('Connection', 'close');
			$connection->send_crlf;
			$connection->print($response->data);
			$connection->close;

		}
	}
}
