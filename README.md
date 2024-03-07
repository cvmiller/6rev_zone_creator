## Synopsis

A Bourne again shell (bash) script to create `bind` reverse IPv6 zone data. [RFC 1034 Sect 5.2.1.2](https://datatracker.ietf.org/doc/html/rfc1034#section-5.2.1) specifies the forward and reverse zone file formats, with the reversed format as a reversed dotted format, for example:

```
4.3.2.1.IN-ADDR.ARPA    IN  PTR host.example.com.
```


## Motivation

Given the standard above, the reverse file for IPv6 becomes rather challenging. For example, the IPv6 address for host.example.com may be `2001:db8:a1ea:cafe::2048` The reverse record would be:

```
8.4.0.2.0.0.0.0.0.0.0.0.0.0.0.0.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	host.example.com.

```
As you can see this is not a transformation you want to do by hand more than once.

Reverse zone files are very useful when using tools such as `tcpdump` or `wireshark`, as they will do a reverse DNS lookup (based on the IP address), and provide host name information in the packet capture, making it easier to determine traffic conversations.

The script is written in bash shell, so that it can run on small embedded systems, such as my OpenWrt router which is running `bind`. 


### The Script

The script does not create an entire reverse zone file. The top portion will be configured for you DNS server, and this script does not try to replace or understand that configuration.

The script does read the forward file and parses out the following:

* The ORIGIN to obtain the domain name (part of the Fully Qualified Domain Name, FQDN)
* The AAAA records which are parsed into IPv6 address and host names


### Why Bash?

Bash is terrible at string handling, why write this script in bash? Because I wanted it to run on my router (OpenWRT), and just about every where else, with the minimal amount of dependencies. It is possible to run Python on OpenWRT, but Python requires more storage (more packages) than just `bash`.

## Examples



**Help**


```
$ ./6rev_zone_creator.sh -h
	./6rev_zone_creator.sh - IPv6 Reverse DNS Zone Creator for BIND 
	e.g.  ./6rev_zone_creator.sh -f <zonefile>  
	-f  <zonefile>
	
 By Craig Miller - Version: 0.93

```

**Generating reverse zone data:**

```
$ ./6rev_zone_creator.sh -f /tmp/example.com.zone
7.1.1.a.3.d.e.f.f.f.d.1.4.2.2.0.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6obake.example.com.
4.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6ha.example.com.
a.1.f.0.e.c.e.f.f.f.4.2.1.1.2.0.0.1.0.0.d.b.b.e.0.7.4.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6maile.example.com.
3.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.d.b.b.e.0.7.4.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6palapala.example.com.
8.c.b.d.1.e.e.f.f.f.4.2.1.1.2.0.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6halaconia.example.com.
7.7.1.8.e.a.e.f.f.f.d.d.a.9.2.1.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6kukuilani.example.com.
3.4.c.3.f.1.8.6.4.e.a.7.4.8.d.2.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6koamx.example.com.
...
a.7.4.2.9.f.b.a.1.1.d.b.0.6.3.7.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6eono.example.com.
e.f.2.6.0.8.e.f.f.f.7.2.0.0.a.0.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6devuan.example.com.
a.f.e.4.a.e.e.f.f.f.7.2.0.0.a.0.e.f.a.c.a.e.1.a.8.b.d.0.1.0.0.2.ip6.arpa.  	IN  	PTR  	6alpine.example.com.

;Pau
```


## Dependencies
The script is dependent on `bash` for array support, and `grep`, both of which should be readily available on any linux distro.

Additionally, it relies on `expand6.sh` available on [github.com/cvmiller/expand6](https://github.com/cvmiller/expand6)

## Contributors

All code by Craig Miller cvmiller at gmail dot com. But ideas, and ports to other languages are welcome. 


## License

This project is open source, under the GPLv2 license (see [LICENSE](LICENSE))
