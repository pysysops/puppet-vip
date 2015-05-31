# Remove IP to device
define rc::vip::del (
  $dev = 'lo',
) {
  exec {
    "vip_del_${name}":
      command => "ip addr del ${name} dev ${dev}",
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      onlyif  => "[ $(ip addr show ${dev} | grep -c inet) -gt 1 ]",
  }
}
