#
# Class to install arno-iptables-firewall script and configure it.-
#
class arno(
	$ext_if,
	$int_net,
	$services_tcp = '22',
	$int_if
) {
	
	# Setup later as args and move to defaults.pp
	$preseed_file = '/root/.puppet-arno.preseed'

	# Preseed file for installing
	file { $preseed_file :
		ensure => present,
		owner  => root,
		group  => root,
		mode   => 600
	}

	package{ 'arno-iptables-firewall' :
		ensure => present,
		responsefile => $preseed_file,
	}

}