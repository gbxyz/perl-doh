# DNS-over-HTTPS (DoH) tools for Perl

See:

* https://tools.ietf.org/html/draft-ietf-doh-dns-over-https

This repository contains:

## `dohc.pl` (DoH client)

This script implements a simple dig-like DoH client using `Net::DNS` and `LWP`.

Usage:

```
$ dohc.pl OPTIONS
```

where `OPTIONS` can be any of the following (in any order):

* `QNAME` - query name. mandatory
* `QTYPE` - query type, any RR type supported by your version of `Net::DNS` will work. Defaults to `A` if unset.
* `QCLASS` - query class, defaults to `IN`
* `URL` - this may be either a fully-qualified URL such as `https://example.com/dns-query` or a string of the form
    ````
    @example.com
    ````
    This will get turned into the HTTPS URL above.

The full DNS response will be printed to `STDOUT`.

## `dohd.pl` (DoH server)

This script implements a simple DoH swerver using `Net::DNS` and `HTTP::Daemon`. You will need to put something in front of it to do SSL termination.
