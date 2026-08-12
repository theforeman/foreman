module HostStatus
  class BuildStatus < Status
    PENDING = 1
    TOKEN_EXPIRED = 2
    BUILD_FAILED = 3
    BUILT = 0

    OK_STATUSES = [PENDING, BUILT]
    WARN_STATUSES = []
    ERROR_STATUSES = [TOKEN_EXPIRED, BUILD_FAILED]

    LABELS = {
      PENDING => N_("Pending installation"),
      TOKEN_EXPIRED => N_("Token expired"),
      BUILD_FAILED => N_("Installation error"),
      BUILT => N_("Installed"),
    }.freeze

    SEARCH = {
      PENDING => 'build_status = pending',
      TOKEN_EXPIRED => 'build_status = token_expired',
      BUILD_FAILED => 'build_status = build_failed',
      BUILT => 'build_status = built',
    }.freeze

    def self.status_name
      N_("Build")
    end

    def to_label(options = {})
      LABELS.fetch(to_status, N_("Unknown build status"))
    end

    def to_global(options = {})
      status = to_status

      return HostStatus::Global::ERROR if ERROR_STATUSES.include?(status)
      return HostStatus::Global::WARN if WARN_STATUSES.include?(status)

      HostStatus::Global::OK
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

    def self.computed_status_sql
      token_expired_clause = if Setting[:token_duration] != 0
                               "WHEN hosts.build = true AND tokens.id IS NOT NULL AND tokens.expires < CURRENT_TIMESTAMP THEN #{TOKEN_EXPIRED}"
                             end

      <<~SQL.squish
        CASE
          #{token_expired_clause}
          WHEN hosts.build = true
          THEN #{PENDING}
          WHEN hosts.build_errors IS NOT NULL
          THEN #{BUILD_FAILED}
          ELSE #{BUILT}
        END
      SQL
    end

    def self.computed_status_joins
      "LEFT JOIN tokens ON tokens.host_id = #{table_name}.host_id"
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
  end
end

HostStatus.status_registry.add(HostStatus::BuildStatus)
