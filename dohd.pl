#!/usr/bin/perl
# Simple DNS-over-HTTPS server. Copyright 2018 CentralNic Ltd
use Getopt::Long;
use HTTP::Daemon;
use MIME::Base64;
use Net::DNS;
use URI;
use strict;

my $ct = 'application/dns-message';
my $laddr = '127.0.0.1';
my $lport = '8080';
my $raddr = '1.1.1.1';

my $resolver = Net::DNS::Resolver->new('nameservers' => [ $raddr ]);

my $server = HTTP::Daemon->new(
	'LocalAddr'	=> $laddr,
	'LocalPort'	=> $lport,
);

if (!$server) {
	printf(STDERR "Unable to start server on %s:%u: %s\n", $laddr, $lport, $@);
	exit(1);

} else {
	printf(STDERR "DoH server running on %s\n", $server->url);

}

#
# listen for connections
#
while (my $connection = $server->accept) {

	printf(STDERR "Connection from %s\n", $connection->peerhost);

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
		printf(STDERR "%s: %s\n", $connection->peerhost, $@);
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
		if ($request->header('Content-Type') ne $ct) {
			printf(STDERR "%s 415 (type is '%s')", $connection->peerhost, $request->header('Content-Type'));
			$connection->send_error(415);

		} else {
			$data = $request->content;

		}

	} else {
		printf(STDERR "%s 405 (method is '%s')", $connection->peerhost, $request->method);
		$connection->send_error(405);
		return;

	}

	my $packet = Net::DNS::Packet->new(\$data);

	if (!$packet) {
		printf(STDERR "%s 400\n", $connection->peerhost);
		$connection->send_error(400);
		return;

	} else {
		#
		# send the packet to the server
		#
		my $response = $resolver->send($packet);

		if (!$response) {
			printf(STDERR "%s 504\n", $connection->peerhost);
			$connection->send_error(504);

		} else {
			printf(STDERR "%s %s %s\n", $connection->peerhost, ($response->question)[0]->qname, lc($response->header->rcode));

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
