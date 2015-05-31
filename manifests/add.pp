# Add IP to device
define rc::vip::add (
  $dev = 'lo',
) {
  exec {
    "vip_add_${name}":
      command => "ip addr add ${name} dev ${dev}",
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      onlyif  => "ip addr show ${dev} | grep -q ${name} && exit 1 || exit 0",
  }
}
