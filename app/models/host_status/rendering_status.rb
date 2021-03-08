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
      SAFEMODE_WARN => N_('Safe mode warning'),
      UNSAFEMODE_WARN => N_('Unsafe mode warning'),
      SAFEMODE_ERROR => N_('Safe mode error'),
      UNSAFEMODE_ERROR => N_('Unsafe mode error'),
    }.freeze

    SEARCH = {
      SAFEMODE_OK => 'rendering_status = safemode_ok',
      UNSAFEMODE_OK => 'rendering_status = unsafemode_ok',
      SAFEMODE_WARN => 'rendering_status = safemode_warn',
      UNSAFEMODE_WARN => 'rendering_status = unsafemode_warn',
      SAFEMODE_ERROR => 'rendering_status = safemode_error',
      UNSAFEMODE_ERROR => 'rendering_status = unsafemode_error',
    }.freeze

    def self.status_name
      N_('Rendering')
    end

    has_many :combinations, class_name: 'HostStatus::RenderingStatusCombination',
                            inverse_of: :host_status,
                            primary_key: :host_id,
                            foreign_key: :host_id
    has_many :templates, through: :combinations

    delegate :destroy_stale_rendering_status_combinations, to: :host

    def self.new(**kwargs, &block)
      super(kwargs.except(:type), &block)
    end

    def delete
      combinations.destroy_all
    end

    def to_label
      LABELS.fetch(to_status, N_('Unknown rendering status'))
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

    def refresh
      combinations.each(&:refresh)
      destroy_stale_rendering_status_combinations
    end

    def refresh!
      refresh
    end

    def status_link
      Rails.application.routes.url_helpers.rendering_status_path(global_id)
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
