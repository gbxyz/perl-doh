#!/usr/bin/perl
# Simple DNS-over-HTTPS client. Copyright 2018 CentralNic Ltd
use Net::IP;
use Net::DNS;
use Net::DNS::Parameters;
use HTTP::Request::Common;
use LWP::UserAgent;
use Getopt::Long;
use URI;
use strict;

my $ct = 'application/dns-message';

my ($qname, $qtype, $qclass, $url, $debug);

#
# dig-like command lines, things can appear in any order
#
# URL can be explicit, if it starts with https:// or http://, or
# if it starts with @, will be constructed, ie @example.com =>
# https://example.com/dns-query
#
while (scalar(@ARGV) > 0) {
	my $param = shift(@ARGV);

	if ($param =~ /^(-d|--debug)$/) {
		$debug = 1;

	} elsif ($param =~ /^(@|https?:\/\/)(.+)$/) {
		if ($url) {
			print STDERR "Error: multiple URLs provided\n";
			exit;

		} else {
			if ('@' eq $1) {
				$url = sprintf('https://%s/dns-query', $2);

			} else {
				$url = $param;

			}
		}

	} elsif ($Net::DNS::Parameters::classbyname{$param}) {
		if ($qclass) {
			print STDERR "Error: multiple classes provided\n";
			exit;

		} else {
			$qclass = $param;

		}

	} elsif ($Net::DNS::Parameters::typebyname{$param}) {
		if ($qtype) {
			print STDERR "Error: multiple types provided\n";
			exit;

		} else {
			$qtype = $param;

		}

	} elsif ($qname) {
		print STDERR "Error: multiple query names provided\n";
		exit;

	} else {
		$qname = $param;

	}
}

$qtype = $qtype || 'A';
$qclass = $qclass || 'IN';

if (!$qname) {
	print STDERR "Error: no query name provided\n";
	exit(1);

} elsif (!$url) {
	print STDERR "Error: no URL provided\n";
	exit(1);

}

$qname =~ s/\.$//g;
my $packet = Net::DNS::Packet->new($qname.'.', $qtype, $qclass);

my $request = POST($url, 'Content-Type' => $ct, 'Content' => $packet->data);
$request->header('Accept' => $ct);

print STDERR $request->as_string if ($debug);

my $response = LWP::UserAgent->new->request($request);

print STDERR $response->as_string if ($debug);

if ($response->is_error || 200 != $response->code) {
	print STDERR $response->status_line."\n";
	exit(1);

} else {
	my $data = $response->content;
	my $answer = Net::DNS::Packet->new(\$data);
	$answer->print;

}