Puppet::Type.newtype(:local_error) do
  @doc = <<-EOT
    Just a type and provider that will throw an arbitrary local error
  EOT

  ensurable

  def refresh
    provider.create
  end

  newparam(:message, namevar: true)
end
