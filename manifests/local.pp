# Installs a profile locally with `profiles`
define mac_profiles_handler::local(
  $file_source = '',
  $ensure = 'present',
  $type = 'mobileconfig'
) {

    case $ensure {
    'absent': {
      profile_manager { $name:
        ensure    => $ensure,
      }
    }
    default: {
      File {
        owner  => 'root',
        group  => 'wheel',
        mode   => '0700',
      }

      if ! defined(File["${facts['puppet_vardir']}/mobileconfigs"]) {
        file { "${facts['puppet_vardir']}/mobileconfigs":
          ensure => directory,
        }
      }
      case $type {
        'template': {
          file { "${facts['puppet_vardir']}/mobileconfigs/${name}":
            ensure  => file,
            content => $file_source,
          }
        }
        default: {
          file { "${facts['puppet_vardir']}/mobileconfigs/${name}":
            ensure => file,
            source => $file_source,
          }
        }
      }
      profile_manager { $name:
        ensure    => $ensure,
        profile   => "${facts['puppet_vardir']}/mobileconfigs/${name}",
        require   => File["${facts['puppet_vardir']}/mobileconfigs/${name}"],
        subscribe => File["${facts['puppet_vardir']}/mobileconfigs/${name}"],
      }
    }
  }
}
