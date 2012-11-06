#
# Class to install arno-iptables-firewall script and configure it.-
#
class arno(
	$ext_if,
	$services_tcp = '22',
	$int_if,
	$int_net,
	$nat,
	$int_nat_net,
	$patch_public_nat_from_inside = false,
	$dynamic_ip = 'false'
) {
	include concat::setup
		
	# Setup later as args and move to defaults.pp
	$preseed_file = '/root/.puppet-arno.preseed'
	$patch_file   = '/root/.puppet-arno.patch'

	# Preseed file for installing
	file { $preseed_file :
		ensure => present,
		owner  => root,
		group  => root,
		mode   => 600,
		content => template('arno/arno.preseed.erb')
	}

	package{ 'arno-iptables-firewall' :
		ensure => present,
		responsefile => $preseed_file,
		require      => File[ $preseed_file ]
	}

	# Change firewall.conf to read nat from outside files
	file { '/etc/arno-iptables-firewall/firewall.conf' :
		ensure => present,
		owner  => root,
		group  => root,
		mode   => 600,
		source => 'puppet:///arno/firewall.conf',
		require => Package['arno-iptables-firewall']
	}

	# Define basic concat for tcp forward, udp forward and custom rules
	concat { [ '/etc/arno-iptables-firewall/nat-forward-tcp.conf', 
		   '/etc/arno-iptables-firewall/nat-forward-udp.conf', 
		   '/etc/arno-iptables-firewall/custom-rules.conf' ] :
		owner => root,
		group => root,
		mode  => 600,
		require => Package['arno-iptables-firewall']
	}
	concat::fragment { 'concat-forward-tcp-header' :
		target => '/etc/arno-iptables-firewall/nat-forward-tcp.conf', 
		content => "# This file is managed by puppet, all changes will be lost on next puppet run\n"
	}
	concat::fragment { 'concat-forward-udp-header' :
		target => '/etc/arno-iptables-firewall/nat-forward-udp.conf', 
		content => "# This file is managed by puppet, all changes will be lost on next puppet run\n"
	}
	concat::fragment { 'concat-custom-rules-header' :
		target => '/etc/arno-iptables-firewall/custom-rules', 
		content => "# This file is managed by puppet, all changes will be lost on next puppet run\n"
	}

	if $patch_public_nat_from_inside {
		file { $patch_file :
			owner  => root,
			group  => root,
			mode   => 600,
			source => 'puppet:///arno/arno.patch',
			notify => Exec['apply_arno_patch'],
			require => Package['arno-iptables-firewall']
		}

		exec { 'apply_arno_patch' :
			command     => "patch /usr/sbin/arno-iptables-firewall $patch_file",
			path        => '/usr/bin:/bin',
			unless      => 'grep -q "# Add support to access public nat from internal network" /usr/sbin/arno-iptables-firewall',
			refreshonly => true,
			require     => File[$patch_file]
		}

	}

}