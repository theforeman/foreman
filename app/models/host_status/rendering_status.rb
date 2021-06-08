module HostStatus
  class RenderingStatus < Status
    include Authorizable

    self.table_name = 'rendering_statuses_view'

    graphql_type '::Types::RenderingStatus'

    SAFEMODE_OK = 0
    UNSAFEMODE_OK = 1
    SAFEMODE_WARN = 2
    UNSAFEMODE_WARN = 3
    SAFEMODE_ERROR = 4
    UNSAFEMODE_ERROR = 5

    OK_STATUSES = [SAFEMODE_OK, UNSAFEMODE_OK]
    WARN_STATUSES = [SAFEMODE_WARN, UNSAFEMODE_WARN]
    ERROR_STATUSES = [SAFEMODE_ERROR, UNSAFEMODE_ERROR]

    LABELS = {
      SAFEMODE_OK => N_('Safe mode OK'),
      UNSAFEMODE_OK => N_('Unsafe mode OK'),
      UNSAFEMODE_WARN => N_('Unsafe mode warning'),
      SAFEMODE_WARN => N_('Safe mode warning'),
      UNSAFEMODE_ERROR => N_('Unsafe mode error'),
      SAFEMODE_ERROR => N_('Safe mode error'),
    }.freeze

    def self.status_name
      N_('Rendering Status')
    end

    has_many :combinations, class_name: 'HostStatus::RenderingStatusCombination',
                            inverse_of: :host_status,
                            primary_key: :host_id,
                            foreign_key: :host_id
    has_many :templates, through: :combinations

    def to_label
      LABELS.fetch(status, N_('Unknown'))
    end

    def to_status
      status
    end

    def to_global(_options = {})
      case status
      when SAFEMODE_ERROR, UNSAFEMODE_ERROR
        HostStatus::Global::ERROR
      when SAFEMODE_WARN, UNSAFEMODE_WARN
        HostStatus::Global::WARN
      else
        HostStatus::Global::OK
      end
    end

    def readonly?
      true
    end

    def status_link
      Rails.application.routes.url_helpers.rendering_status_path(global_id)
    end

    def forget_status_host_path
      Rails.application.routes.url_helpers.forget_rendering_status_host_path(host, status: self)
    end

    def global_id
      Foreman::GlobalId.for(self)
    end

    def type
      self.class.to_s
    end
  end
end

HostStatus.status_registry.add(HostStatus::RenderingStatus)
