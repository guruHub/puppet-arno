puppet-arno
===========

Puppet code to setup a firewall/gateway using arno-iptables-firewall on Debian Squeeze.

It provides a resource to add port forwarding rules to internal services.

Example Usage Simple Gateway
--------------------------------

Let's suppose a machine have two network cards:
* eth0 - IP 1.1.1.1       - Connected to internet
* eth1 - IP 192.168.100.1 - Connected to private network 192.168.100.0/24

And you only want access to the gateway through SSH, code would look like this:
```puppet
class{'arno' :
       ext_if       => 'eth0',
       int_if       => 'eth1',
       services_tcp => '22',
       int_net      => '192.168.100.0/24',
       int_nat_net  => '192.168.100.0/24',
       nat          => 'true',
       patch_public_nat_from_inside => true,
}
```

If you don't set patch_public_nat_from_inside or set to false you will have the official version from debian.

Example Usage Port Forwarding
------------------------------

Same as above, pluse to forward port 80 to internal machine 192.168.100.10 you will need to call
resource arno::openport for each port you want to open on the firewall. In this case:
```puppet
arno::openport { 'webforwarding-example' :
	proto => 'tcp',
	ext_ip   => '1.1.1.1',
	ext_port => '80',
	int_ip   => '192.168.100.10',
}		
```
  
Arguments Explained
--------------------

_Class arno_
* ext_if       = External Interface
* int_if       = Internal Interface
* services_tcp = String separated by whitespaces of port list to locally open for firewall services.
* int_net      = Internal Network
* int_nat_net  = Internal Network that should have internet access
* nat          = Set to 'true' to provide internet to internal machines, 'false' to don't.

Optional:
* patch_public_nat_from_inside = Will apply a patch to support using public NAT ip's from the network behind the firewall.

_Resource arno::openport_

Required:
* proto    => Protocol of port to forward.
* ext_ip   => External IP
* ext_port => External port to forward.
* int_ip   => Forward destination

Optional:
* int_port => Internal port destination, if missing will be equal to ext_port.
* source   => Limit forwarding only to a given network source, by default '0/0'


Optional patch
--------------

The optional patch was done by me to give support to use public nat IP's from the
network behind the nat.


To apply the patch you need to set to true the argument "patch_public_nat_from_inside"


Warnings
--------

* Arno Version

This is not for the latest version of arno iptables firewall (aif) and have not been tested with it, this is for the latest Debian Squeeze Version.

* Argument 'nat' expects 'true' or 'false' *as string*, not real true or false. If you don't set nat => 'true' internal machines won't have Internet access.

Info
----

* Author: Guzmán Brasó <guzman@guruhub.com.uy>
* Contributor: Gastón Acosta <gaston@guruhub.com.uy>
* Homepage: http://github.com/guruHub/puppet-arno
