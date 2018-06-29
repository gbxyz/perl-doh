# NAME

`dohd`, a DNS over HTTPS (DoH) server.

# DESCRIPTION

`dohd` is a simple DoH server built using [Net::DNS](https://metacpan.org/pod/Net::DNS) and [HTTP::Daemon](https://metacpan.org/pod/HTTP::Daemon).
It accepts HTTP requests containing DNS queries, forwards them to a DNS server,
and sends the response back to the client.

# SYNOPSIS

        dohd OPTIONS

# OPTIONS

- `--addr=ADDR` - address to listen on, defaults to `127.0.0.1`.
- `--port=PORT` - port to listen on, defaults to `8080`.
- `--resolver=ADDR` - DNS server to forward queries to, defaults to `127.0.0.1`.
- `--debug` - enables debug mode for `HTTP::Daemon` and `Net::DNS::Resolver`.
- `--daemon` - daemonise, otherwise, `dohd` stays in the foreground.
- `--help` - display help.

## Supporting HTTPS and HTTP/2

The DoH specification ([https://tools.ietf.org/html/draft-ietf-doh-dns-over-https](https://tools.ietf.org/html/draft-ietf-doh-dns-over-https))
makes support for HTTPS mandatory, and says that you SHOULD support HTTP/2.

This can be achieved fairly easily by using `nghttpx`,
([https://nghttp2.org/documentation/nghttpx.1.html](https://nghttp2.org/documentation/nghttpx.1.html)) as a reverse proxy sitting
in front of `dohd`:

        nghttpx -b 127.0.0.1,8080 -f 127.0.0.1,4430 server.key server.crt

The above command will accept HTTP/2 connections over HTTPS on `127.0.0.1`
port `4430` and forward them as HTTP/1.1 connections to `127.0.0.1` port
`8080`.

# COPYRIGHT

Copyright 2018 CentralNic Ltd. All rights reserved.

# LICENSE

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of the author not be used
in advertising or publicity pertaining to distribution of the software
without specific prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
