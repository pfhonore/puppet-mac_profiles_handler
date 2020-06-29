Puppet::Type.type(:local_error).provide :macos do
  desc "Returns an arbitrary error on macOS"

  confine operatingsystem: :darwin

  defaultfor operatingsystem: :darwin

  def create
    error()
  end

  def destroy
    error()
  end

  def exists?
    # This will never exist
    false
  end

  def error
    message = resource["message"]
    raise Puppet::Error, message
  end
end
