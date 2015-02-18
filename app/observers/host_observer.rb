class HostObserver < ActiveRecord::Observer
  observe Host::Base

  # Sets and expire provisioning tokens
  # this has to happen post validation and before the orchesration queue is starting to
  # process, as the token value is required within the tftp config file manipulations
  def after_validation(host)
    return unless SETTINGS[:unattended]
    # new server in build mode
    if host.new_record? and host.build?
      host.set_token
    end
    # existing server change build mode
    if host.respond_to?(:old) and host.old and host.build? != host.old.build?
      host.build? ? host.set_token : host.expire_token
    end
  end
end
