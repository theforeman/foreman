module HostStatus
  class TemplatesRenderingStatusCombination < ::ApplicationRecord
    belongs_to_host
    belongs_to :template, class_name: 'ProvisioningTemplate'
    belongs_to :host_status, inverse_of: :combinations,
                             class_name: 'HostStatus::TemplatesRenderingStatus',
                             primary_key: :host_id,
                             foreign_key: :host_id

    validates :host, uniqueness: { scope: :template }
    validates :host, presence: true
    validates :template, presence: true
    validates :status, presence: true

    scope :not_pending, -> { where.not(status: HostStatus::TemplatesRenderingStatus::PENDING) }

    def refresh_status
      assign_attributes(status: to_status)
    end

    def to_status
      return HostStatus::TemplatesRenderingStatus::UNSAFEMODE_ERRORS if !Setting::Provisioning[:safemode_render] && !render_unsafemode
      return HostStatus::TemplatesRenderingStatus::SAFEMODE_ERRORS unless render_safemode

      HostStatus::TemplatesRenderingStatus::OK
    end

    private

    def render_safemode
      template.render(renderer: Foreman::Renderer::SafeModeRenderer, host: host)
      true
    rescue StandardError => e
      Foreman::Logging.exception("#{self.class} Safemode Error", e)
      false
    end

    def render_unsafemode
      template.render(renderer: Foreman::Renderer::UnsafeModeRenderer, host: host)
      true
    rescue StandardError => e
      Foreman::Logging.exception("#{self.class} Unsafemode Error", e)
      false
    end
  end
end
