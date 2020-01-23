# Installs a profile with MDM
define mac_profiles_handler::mdm (
    $file_source = '',
    $ensure = 'present',
    $type = 'template',
) {

  if $type != 'template' {
    fail('Only template type is supported with MDM.')
  }

  if $facts['mdmenrollemnt']['mdm_enrolled'] == false {
    fail('Device is not enrolled in MDM.')
  }

  $profiles = $facts['profiles']

  $mdmdirector_host = lookup('mac_profiles_handler::mdmdirector_host', String)
  $mdmdirector_username = lookup('mac_profiles_handler::mdmdirector_username', String)
  $mdmdirector_password = lookup('mac_profiles_handler::mdmdirector_password', String)


  $mdmdirector_path = lookup('mac_profiles_handler::mdmdirector_path', String, 'first', '/profile')
  $udid = $facts['system_profiler']['hardware_uuid']

  $output = send_mdm_profile(
    $file_source,
    $udid,
    $ensure,
    $mdmdirector_password,
    $mdmdirector_username,
    $mdmdirector_host,
    $mdmdirector_path
    )


  if $facts['mdmenrollment']['dep_enrolled'] == false {
    $plist = plist_to_hash($file_source)

    if has_key($profiles, $plist['PayloadIdentifier']) {
      $new_hash = $output['profile_metadata'][0]['hashed_payload_uuid']

      if $profiles[$plist['PayloadIdentifier']]['uuid'] != $new_hash {
        exec { "remove ${plist['PayloadIdentifier']['uuid']}":
            command => "/usr/bin/profiles -R -p ${plist['PayloadIdentifier']}",
        }
      }
    }
  }
}
