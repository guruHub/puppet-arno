#
# Resource to open a port on arno
#
define arno::openport(
	$proto,
	$ext_ip,
	$ext_port,
	$int_ip,
	$int_port = '',
	$source   = '0/0'
) {

	if $int_port == '' {
		$real_int_port = $ext_port,
	} else {
		$real_int_port = $int_port
	}

	concat::fragment{"arno_openport_${name}":
		target => $proto ? {
			'tcp' => '/etc/arno-iptables-firewall/nat-forward-tcp.conf',
			'udp' => '/etc/arno-iptables-firewall/nat-forward-udp.conf'
		},
		content => "${ext_ip}#${source}~${ext_port}>${int_ip}~${real_int_port}\n"
	}

}
