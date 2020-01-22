# manage mac profiles
define mac_profiles_handler::manage(
  $file_source = '',
  $ensure = 'present',
  $type = 'mobileconfig',
  $method = 'local'
) {

  if $facts['os']['name'] != 'Darwin' {
    fail('The mobileconfig::manage resource type is only supported on macOS')
  }

  case $method {
    'mdm': {
      mac_profiles_handler::mdm {$name:
        ensure      => $ensure,
        file_source => $file_source,
        type        => $type

      }
    }
    default: {
      mac_profiles_handler::local{$name:
        ensure      => $ensure,
        file_source => $file_source,
        type        => $type,
      }
    }
  }



}

