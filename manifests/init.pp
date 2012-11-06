#
# Class to install arno-iptables-firewall script and configure it.-
#
class arno {
	
	package{ 'arno-iptables-firewall' :
		ensure => present,
	}
}