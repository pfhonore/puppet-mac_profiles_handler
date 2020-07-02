# Installs a profile with MDM
define mac_profiles_handler::mdm (
    $file_source = '',
    $ensure = 'present',
    $type = 'template',
) {

  $payload_identifier = $name

  $enrolled = $facts['mdmenrollment']['mdm_enrolled']

  if $type != 'template' {
    $munged_source = regsubst($file_source, 'puppet:///modules/', '', 'G')
    notify{$munged_source: }
    $input = file($munged_source)
  } else {
    $input = $file_source
  }

  if $enrolled == false {
    notify {"Device is not enrolled in MDM. ${payload_identifier}":
      loglevel => 'err',
    }
  }

  if $enrolled and $type == 'template' {

    $profiles = $facts['profiles']

    $mdmdirector_host = lookup('mac_profiles_handler::mdmdirector_host', String)
    $mdmdirector_username = lookup('mac_profiles_handler::mdmdirector_username', String)
    $mdmdirector_password = lookup('mac_profiles_handler::mdmdirector_password', String)


    $mdmdirector_path = lookup('mac_profiles_handler::mdmdirector_path', String, 'first', '/profile')
    $udid = $facts['system_profiler']['hardware_uuid']

    $output = send_mdm_profile(
      $input,
      $udid,
      $ensure,
      $mdmdirector_username,
      $mdmdirector_password,
      $mdmdirector_host,
      $mdmdirector_path
      )

      $status = $output[0]['profile_metadata'][0]['status']
      if $status == 'pushed' {
        notify{"${name} was pushed to ${udid}": }
      }

    if $facts['mdmenrollment']['dep_enrolled'] == false {
      if $ensure == 'absent' and has_key($profiles, $payload_identifier){
        exec { "remove ${payload_identifier}":
            command => "/usr/bin/profiles -R -p ${payload_identifier}",
            returns => [0,1]
        }
      } else {
        if has_key($profiles, $payload_identifier) {
          $new_hash = $output[0]['profile_metadata'][0]['hashed_payload_uuid']
          if $profiles[$payload_identifier]['uuid'] != $new_hash {
            exec { "remove ${payload_identifier}":
                command => "/usr/bin/profiles -R -p ${payload_identifier}",
                returns => [0,1]
            }
          }
        }
      }
    }
  }

}
