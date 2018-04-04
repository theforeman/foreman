module HostStatus
  class BuildStatus < Status
    PENDING = 1
    TOKEN_EXPIRED = 2
    BUILT = 0

    def self.status_name
      N_("Build")
    end

    def to_label(options = {})
      case to_status
        when PENDING
          N_("Pending installation")
        when TOKEN_EXPIRED
          N_("Token expired")
        when BUILT
          N_("Installed")
        else
          N_("Unknown build status")
      end
    end

    def to_global(options = {})
      case to_status
        when TOKEN_EXPIRED
          HostStatus::Global::ERROR
        else
          HostStatus::Global::OK
      end
    end

    def to_status(options = {})
      if waiting_for_build?
        if token_expired?
          TOKEN_EXPIRED
        else
          PENDING
        end
      else
        BUILT
      end
    end

    def relevant?(options = {})
      SETTINGS[:unattended] && host.managed?
    end

    def waiting_for_build?
      host&.build
    end

    def token_expired?
      host&.token_expired?
    end
  end
end

HostStatus.status_registry.add(HostStatus::BuildStatus)
