# define: vip
#
# This definition manages virtual IP addresses with iproute.
# It's designed for use with things like keepalived when load balancing.
#
# Parameters:
#   [*ensure*]  - present or absent               - default: present
#   [*address*] - a valid IP address to manage    - default: name
#   [*dev*]     - The device to manage the VIP on - default: lo
#
# Sample Usage:
#
#  vip { '192.168.2.1':
#    ensure => present,
#    dev    => 'lo',
#  }

define vip (
  $ensure = 'present',
  $address = $name,
  $dev = 'lo',
) {

  validate_re($ensure, '^(present|absent)$',
    "Invalid ensure value '${ensure}'. Expected 'present' or 'absent'")
  validate_ip_address($address)
  validate_string($dev)

  if ! defined(Package['iproute']) {
    package { 'iproute':
      ensure => 'installed'
    }
  }

  if ! defined(Package['grep']) {
    package { 'grep':
      ensure => 'installed'
    }
  }

  if $ensure == 'absent' {
    exec {
      "Remove ${address} from ${dev}":
        command => "ip addr del ${name} dev ${dev}",
        path    => '/usr/bin:/usr/sbin:/bin:/sbin',
        onlyif  => "[ $(ip addr show ${dev} | grep -c inet) -gt 1 ] &&\
                    [ $(ip addr show ${dev} | grep -c ${address}) -eq 1 ]",
        require => [ Package['iproute'], Package['grep'] ],
    }
  } else {
    exec {
      "Ensure VIP ${address} on ${dev}":
        command => "ip addr add ${name} dev ${dev}",
        path    => '/usr/bin:/usr/sbin:/bin:/sbin',
        onlyif  => "[ $( ip addr show ${dev} | grep -c ${address}) -eq 0 ]",
        require => [ Package['iproute'], Package['grep'] ],
    }
  }
}
