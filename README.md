# jIP
_JSON-based client-server communication in Bash_

----

This tool provides client-server [JSON]() messaging on a hotfolder, by using [scp]().

Server needs to preemptively enable ssh communication with those clients in order to allow messaging.

SSH communication is expected to occur on a username-password fashion, as oppsed to passwordless access (which would be preferable but cannot be assumed).

The client is validated against its own RSA public key and its hostname and IP address are checked against a local database.

----

## Requirements
### Server
- [bash]():
- [jq]():
- [cron]():
- [ssh]() / [scp]():

### Client
- [bash]():
- [ssh]() / [scp]():
- [cron]():
- [expect](): statically built linux64 binary provided inside this package
