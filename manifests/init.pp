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