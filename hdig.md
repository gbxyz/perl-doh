# NAME

`hdig` a `dig`-like client for DNS over HTTPS (DoH)

# DESCRIPTION

`hdig` is a simple DNS over HTTPS (DoH) client implemented using [Net::DNS](https://metacpan.org/pod/Net::DNS) and [LWP](https://metacpan.org/pod/LWP).

It will construct a DNS query, send it as an HTTP request to a DoH server, and display the response in human-readable format.

# SYNOPSIS

        hdig OPTIONS

# OPTIONS

`hdig` accepts similar command-line options to `dig`, and like `dig`, they can be provided in any order.

- query name. mandatory.
- query type, any RR type supported by your version of [Net::DNS](https://metacpan.org/pod/Net::DNS) will work. Defaults to `A` if unset.
- query class, defaults to `IN`.
- URL. This may be either a fully-qualified URL such as [https://example.com/dns-query](https://example.com/dns-query) or a string of the form

        @example.com

    This will get turned into the HTTPS URL above.

    If no URL is provided, then `hdig` will construct one using the nameserver the system is configured with.

- `--insecure` or `-k`. Disables SSL certification verification.
- `--debug` or `-d`. Enables debug mode.
- `--help` or `-h`. Displays help.

## EXAMPLES

        $ hdig example.com @cloudflare-dns.com

Sends an A query for `example.com` to Cloudflare's DoH server.

        $ hdig AAAA example.com @cloudflare-dns.com

Sends an AAAA record.

        $ hdig CH TXT id.server @example.com

Sends a Chaosnet TXT query for `id.server` to [https://example.com/dns-query](https://example.com/dns-query).

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
