# Installs a profile with MDM
define mac_profiles_handler::mdm (
    $file_source = '',
    $ensure = 'present',
    $type = 'template',
    $mdmdirector_host = '',
    $mdmdirector_username = 'mdmdirector',
    $mdmdirector_password = '',
) {

  if $type != 'template' {
    fail('Only template type is supported with MDM')
  }

  $mdmdirector_host = lookup('mac_profiles_handler::mdmdirector_host', String)
  $mdmdirector_username = lookup('mac_profiles_handler::mdmdirector_username', String)
  $mdmdirector_password = lookup('mac_profiles_handler::mdmdirector_password', String)

  $udid = $facts['system_profiler']['hardware_uuid']

  $output = send_mdm_profile($file_source, $udid, $ensure, $mdmdirector_password, $mdmdirector_username, $mdmdirector_host)

  notify { $output:
  }
}
