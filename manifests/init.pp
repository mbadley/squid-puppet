# Class: squid
#
# Squid 3.x proxy server.
#
# Sample Usage :
#     include squid
#
#     class { 'squid':
#       acl => [
#         'myip XX.XX.XX.1',
#         'myip XX.XX.XX.2',
#         'office src 10.0.0.0/24',
#       ],
#       http_access => [
#         'allow office',
#       ],
#       cache => [ 'deny all' ],
#       via => 'off',
#       tcp_outgoing_address => [
#         'XX.XX.XX.1 ',
#         'XX.XX.XX.2 ',
#       ],
#       server_persistent_connections => 'off',
#     }
#
class squid (
  # Options are in the same order they appear in squid.conf
  $http_port            = [ '3128' ],
  $acl                  = [],
  $http_access          = [],
  $icp_access           = [],
  $tcp_outgoing_address = [],
  $cache_mem            = '256 MB',
  $cache_dir            = [],
  $cache                = [],
  $via                  = 'on',
  $ignore_expect_100    = 'off',
  $cache_mgr            = 'root',
  $forwarded_for        = 'on',
  $client_persistent_connections = 'on',
  $server_persistent_connections = 'on',
  $maximum_object_size           = '4096 KB',
  $maximum_object_size_in_memory = '512 KB',
  $config_hash                   = {},
  $refresh_patterns              = [],
  $template                      = 'long',
) inherits ::squid::params {

  $use_template = $template ? {
    'short' => 'squid/squid.conf.short.erb',
    'long'  => 'squid/squid.conf.long.erb',
    default => $template,
  }

  if ! empty($config_hash) and $use_template == 'long' {
    fail('$config_hash does not (yet) work with the "long" template!')
  }


  package { 'squid_package': ensure => installed, name => $package_name }

  service { 'squid_service':
    enable    => true,
    name      => $service_name,
    ensure    => running,
    restart   => "service ${service_name} reload",
    path      => ['/sbin', '/usr/sbin'],
    hasstatus => true,
    require   => Package['squid_package'],
  }

  file { $config_file:
    require => Package['squid_package'],
    notify  => Service['squid_service'],
    content => template($use_template),
  }

}

