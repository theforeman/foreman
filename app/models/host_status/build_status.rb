module HostStatus
  class BuildStatus < Status
    PENDING = 1
    BUILT = 0

    def self.status_name
      N_("Build")
    end

    def to_label(options = {})
      case to_status
        when PENDING
          N_("Pending installation")
        when BUILT
          N_("Installed")
        else
          N_("Unknown build status")
      end
    end

    def to_status(options = {})
      if waiting_for_build?
        PENDING
      else
        BUILT
      end
    end

    def relevant?
      SETTINGS[:unattended] && host.managed?
    end

    def waiting_for_build?
      host && host.build
    end
  end
end

HostStatus.status_registry.add(HostStatus::BuildStatus)
