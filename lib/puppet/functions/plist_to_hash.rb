# I wish this was Go. Or Python. Or anything else. But here we are.

require 'puppet/util/plist' if Puppet.features.cfpropertylist?

Puppet::Functions.create_function(:plist_to_hash) do

  def plist_to_hash(plist)


      Puppet::Util::Plist.parse_plist(plist)

  end
end