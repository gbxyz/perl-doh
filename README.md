# DNS-over-HTTPS (DoH) tools for Perl

See:

* https://tools.ietf.org/html/draft-ietf-doh-dns-over-https

This repository contains:


## `hdig` (DoH client)

This script implements a simple dig-like DoH client using `Net::DNS` and `LWP`.

Usage:

```
$ hdig OPTIONS
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

This script implements a simple DoH server using `Net::DNS` and `HTTP::Daemon`. You will need to put something in front of it to do SSL termination.

Usage:

```
$ dohd.pl OPTIONS
```

where `OPTIONS` can be any of the following (in any order):

* `--addr=ADDR` - address to listen on, defaults to `127.0.0.1`

* `--port` - port to listen on, defaults to `8080`

* `--resolver` - DNS server to forward queries to, defaults to `127.0.0.1`

* `--debug` - enables debug mode for `HTTP::Daemon` and `Net::DNS::Resolver`

* `--daemon` - daemonise, otherwise, `dohd.pl` stays in the foreground.


### Supporting HTTPS and HTTP/2

The [DoH spec](https://tools.ietf.org/html/draft-ietf-doh-dns-over-https) makes support for HTTPS mandatory, and says that you SHOULD support HTTP/2.

This can be achieved fairly easily by using [nghttpx](https://nghttp2.org/documentation/nghttpx.1.html) as a reverse proxy sitting in front of `dohd.pl`, using the following command:

```
nghttpx -b 127.0.0.1,8080 -f 127.0.0.1,4430 server.key server.crt
```

The above command will accept HTTP/2 connections over HTTPS on 127.0.0.1 port 4430 and forward them as HTTP/1.1 connections to 127.0.0.1 port 8080.
