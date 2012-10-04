class HostObserver < ActiveRecord::Observer

  # Sets and expire provisioning tokens
  # this has to happen post validation and before the orchesration queue is starting to 
  # process, as the token value is required within the tftp config file manipulations
  def after_validation(host)
    # new server in build mode
    if host.new_record? and host.build?
      host.set_token
    end
    # existing server change build mode
    if host.old and host.build? != host.old.build?
      host.build? ? host.set_token : host.expire_tokens
    end
  end

end
