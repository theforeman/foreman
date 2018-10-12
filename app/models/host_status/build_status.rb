module HostStatus
  class BuildStatus < Status
    PENDING = 1
    TOKEN_EXPIRED = 2
    BUILD_FAILED = 3
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
        when BUILD_FAILED
          N_("Installation error")
        else
          N_("Unknown build status")
      end
    end

    def to_global(options = {})
      case to_status
        when TOKEN_EXPIRED, BUILD_FAILED
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
        if build_errors?
          BUILD_FAILED
        else
          BUILT
        end
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

    def build_errors?
      host && host.build_errors.present?
    end

    def remediation_help_text
      case to_status
        when PENDING
          N_("Installation haven't started yet or in progress")
        when TOKEN_EXPIRED
          N_("Build token is no longer valid, cancel build mode and enter it again to generate new token")
        when BUILT
          N_("OS installer reported end of installation and rebooted the system")
        when BUILD_FAILED
          N_("OS installer post script reported failure, check logs")
        else
          N_("The host was not scheduled for build yet")
      end
    end
  end
end

HostStatus.status_registry.add(HostStatus::BuildStatus)
