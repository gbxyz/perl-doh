# NAME

`dohp`, a DNS over HTTPS (DoH) proxy server.

# DESCRIPTION

`dohd` is a simple DNS server built using [Net::DNS](https://metacpan.org/pod/Net::DNS) and [HTTP::Daemon](https://metacpan.org/pod/HTTP::Daemon).
It accepts DNS queries, forwards them to a DNS over HTTPS (DoH) server,
and sends the response back to the client.

# SYNOPSIS

        dohp OPTIONS

# OPTIONS

- `--addr=ADDR` - address to listen on, defaults to
`127.0.0.1`.
- `--port=PORT` - port to listen on, defaults to `5353`.
- `--server=URL` - Name of the server to send DoH queries to.
- `--url=URL` - URL to use instead of a server name.
- `--bootstrap=ADDR` - The IP address of the host specified in
`--server` or `--url`, avoids circular loops where `dohp` is
configured as the system's own resolver.
- `--insecure` - Disable SSL certification verification.
- `--debug` - Enables debug mode for `HTTP::Daemon` and
`Net::DNS::Resolver`.
- `--daemon` - Daemonise, otherwise, `dohd` stays in the
foreground.
- `--help` - display help.

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
