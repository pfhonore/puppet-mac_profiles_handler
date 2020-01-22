# I wish this was Go. Or Python. Or anything else. But here we are.

require 'net/http'
require 'uri'
require 'json'
require 'base64'

require 'puppet/util/plist' if Puppet.features.cfpropertylist?

Puppet::Functions.create_function(:'mac_profiles_handler::send_mdm_profile') do
  dispatch :send_profile do
    param 'String', :mobileconfig
    param 'String', :udid
    param 'String', :ensure
    param 'String', :mdmdirector_password
    param 'String', :mdmdirector_username
    param 'String', :mdmdirector_host
    return_type 'Hash'
  end

  def send_profile(mobileconfig, udid, ensure, mdmdirector_password, mdmdirector_username, mdmdirector_host)

    enc = Base64.encode64(mobileconfig)

    uri = URI.parse(mdmdirector_host)
    if ensure == "absent" do
      request = Net::HTTP::Delete.new(uri.path)
      # also need to parse out the payload id from the plist
      plist = Puppet::Util::Plist.parse_plist(mobileconfig)

      request.body = JSON.dump({
        "udids" => [udid],
        "profiles" => [{
          "uuid" => plist["PayloadIdentifier"],
          "payload_identifier" => plist["PayloadUUID"]
        }],
        "metadata" => true
      })
    else
      request = Net::HTTP::Post.new(uri)
      request.body = JSON.dump({
        "udids" => [udid],
        "profiles" => [enc],
        "metadata" => true
      })
    end
    request.basic_auth(mdmdirector_username, mdmdirector_password)


    req_options = {
      use_ssl: uri.scheme == "https",
    }



    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(request.body)

  end
end
