module HostStatus
  class TemplatesRenderingStatus < Status
    PENDING = 0
    OK = 1
    SAFEMODE_ERRORS = 2
    UNSAFEMODE_ERRORS = 3
    MISSING_TEMPLATE_ERROR = 4

    OK_LABEL = N_('OK')
    SAFEMODE_ERRORS_LABEL = N_('Safe mode Error')
    UNSAFEMODE_ERRORS_LABEL = N_('Unsafe mode Error')
    MISSING_TEMPLATE_ERROR_LABEL = N_('Provisioning Template is missing')
    PENDING_LABEL = N_('Pending')

    def self.status_name
      N_('Templates Rendering Status')
    end

    has_many :combinations, class_name: 'HostStatus::TemplatesRenderingStatusCombination',
                            inverse_of: :host_status,
                            dependent: :destroy,
                            primary_key: :host_id,
                            foreign_key: :host_id
    has_many :templates, through: :combinations

    scope :pending, -> { where(status: PENDING) }

    def to_status(_options = {})
      actual_templates = host.find_templates

      combinations.where.not(template: actual_templates).delete_all
      statuses = actual_templates.map { |template| combinations.find_or_initialize_by(template: template) }
                      .each(&:refresh_status)
                      .each(&:save)
                      .map(&:status)

      return MISSING_TEMPLATE_ERROR unless statuses.any?
      return UNSAFEMODE_ERRORS if statuses.include?(UNSAFEMODE_ERRORS)
      return SAFEMODE_ERRORS if statuses.include?(SAFEMODE_ERRORS)

      OK
    end

    def to_global(_options = {})
      case status
      when UNSAFEMODE_ERRORS, MISSING_TEMPLATE_ERROR
        HostStatus::Global::ERROR
      when SAFEMODE_ERRORS
        HostStatus::Global::WARN
      else
        HostStatus::Global::OK
      end
    end

    def to_label(_options = {})
      label = case status
              when OK
                OK_LABEL
              when SAFEMODE_ERRORS
                SAFEMODE_ERRORS_LABEL
              when UNSAFEMODE_ERRORS
                UNSAFEMODE_ERRORS_LABEL
              when MISSING_TEMPLATE_ERROR
                MISSING_TEMPLATE_ERROR_LABEL
              else
                PENDING_LABEL
              end

      url = url_helpers.templates_rendering_status_path(self)

      "<a href='#{url}'>#{label}</a>".html_safe
    end

    def relevant?(_options = {})
      host.managed?
    end

    delegate :url_helpers, to: 'Rails.application.routes'
  end
end

HostStatus.status_registry.add(HostStatus::TemplatesRenderingStatus)
