class SystemObserver < ActiveRecord::Observer
  observe System::Base

  # Sets and expire provisioning tokens
  # this has to happen post validation and before the orchesration queue is starting to
  # process, as the token value is required within the tftp config file manipulations
  def after_validation(system)
    return unless SETTINGS[:unattended]
    # new server in build mode
    if system.new_record? and system.build?
      system.set_token
    end
    # existing server change build mode
    if system.respond_to?(:old) and system.old and system.build? != system.old.build?
      system.build? ? system.set_token : system.expire_tokens
    end
  end

end
