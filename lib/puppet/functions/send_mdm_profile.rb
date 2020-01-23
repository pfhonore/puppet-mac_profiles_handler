# I wish this was Go. Or Python. Or anything else. But here we are.

require 'net/http'
require 'uri'
require 'json'
require 'base64'

require 'puppet/util/plist' if Puppet.features.cfpropertylist?

Puppet::Functions.create_function(:send_mdm_profile) do

  def send_mdm_profile(mobileconfig, udid, ensure_profile, mdmdirector_password, mdmdirector_username, mdmdirector_host, mdmdirector_path)


    enc = Base64.encode64(mobileconfig)

    uri = URI.parse(mdmdirector_host)
    uri += mdmdirector_path
    if ensure_profile == "absent"
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
        "metadata" => true,
        "push_now" => true
      })
    end
    request.basic_auth(mdmdirector_username, mdmdirector_password)


    req_options = {
      use_ssl: uri.scheme == "https",
    }



    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    # device = JSON.parse(response.body)
    # if device["profile_metadata"][0]["status"] == "pushed" or device["profile_metadata"][0]["status"] == "changed"
    #   state = "changed"
    # else
    #   state = device["profile_metadata"][0]["status"]
    # end

    # for profilelist
    # output = {
    #   "state" => state
    # }
    JSON.parse(response.body)
  end
end