module Foreman
  module Renderer
    class RenderStatusService
      def self.success(host:, provisioning_template:, safemode:)
        call(host, provisioning_template, safemode, true)
      end

      def self.error(host:, provisioning_template:, safemode:)
        call(host, provisioning_template, safemode, false)
      end

      def self.call(host, provisioning_template, safemode, success)
        return unless host

        klass = host.persisted? ? ExistingHostService : NewHostService
        klass.new(host, provisioning_template, safemode, success).call
      end

      class BaseService
        def initialize(host, provisioning_template, safemode, success)
          @host = host
          @provisioning_template = provisioning_template
          @safemode = safemode
          @success = success
        end

        private

        attr_reader :host, :provisioning_template, :safemode, :success
        delegate :render_statuses, to: :host
        delegate :id, to: :provisioning_template, prefix: true
      end

      class ExistingHostService < BaseService
        def call
          render_statuses.find_or_initialize_by(provisioning_template: provisioning_template, safemode: safemode)
                         .update(success: success)
        end
      end

      class NewHostService < BaseService
        def call
          update || create
        end

        private

        def update
          render_statuses.find { |status| status.template_id == provisioning_template_id && status.safemode == safemode }
                         .tap { |status| status&.assign_attributes(success: success) }
        end

        def create
          render_statuses.new(provisioning_template: provisioning_template, safemode: safemode, success: success)
        end
      end
    end
  end
end
