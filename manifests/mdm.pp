# Installs a profile with MDM
define mac_profiles_handler::mdm (
    $file_source = '',
    $ensure = 'present',
    $type = 'mobileconfig',
    $method = 'local',
    $mdmdirector_host = '',
    $mdmdirector_username = 'mdmdirector',
    $mdmdirector_password = '',
) {
  # get content of desired profile (profile ID and payload)
  # get current profile out of mdmdirector

  # get supervised state out of mdmdirector - if device is 10.15 and supervised we can just push

  # if profile is managed (by mdm) we can push

  # if not supervised and not 10.15, attempt a local profile removal

  # if profile doesn't exist, push
}
