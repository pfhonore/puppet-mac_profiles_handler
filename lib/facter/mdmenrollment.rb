# mdmemrollment.rb

Facter.add(:mdmenrollment) do
  confine osfamily: 'Darwin'
  setcode do
    output = {}

    profiles_output = Facter::Util::Resolution.exec('/usr/bin/profiles status -type enrollment')
    if $CHILD_STATUS.exitstatus.zero?
      # We're on macOS that supports this
      # iterate over every line and see if we're enrolled via mdm,
      # enrolled via dep and if it's user approved
      profiles_output.each_line do |output_line|
        line_array = output_line.split(":")
        # enrolled in mdm? (should this take the name of the output above?)
        # we're also checking user approval here
        if line_array[0] == 'MDM enrollment'
          if line_array[1].strip == 'Yes'
            output['mdm_enrolled'] = true
            output['user_approved'] = false
          elsif line_array[1].strip == 'Yes (User Approved)'
            output['mdm_enrolled'] = true
            output['user_approved'] = true
          else
            output['mdm_enrolled'] = false
            output['user_approved'] = false
          end
        end

        # enrolled via dep?
        if line_array[0] == 'Enrolled via DEP'
          if line_array[1].strip == 'Yes'
            output['dep_enrolled'] = true
          else
            output['dep_enrolled'] = false
          end
        end
      end
    end

    output
  end
end
