module Foreman
  module Rendering
    class BaseSubscriber < ::Foreman::BaseSubscriber
      def call(event)
        @host_id = event.payload[:host_id]
        @template_id = event.payload[:template_id]

        return unless template_id && host_id
        return unless Host::Managed.unscoped.exists?(id: template_id)
        return unless ProvisioningTemplate.unscoped.exists?(id: host_id)

        update_combination
        update_warnings
        refresh_global_statuses
      end

      private

      attr_reader :host_id, :template_id

      def combination
        @combination ||= HostStatus::RenderingStatusCombination.find_or_initialize_by(host_id: host_id, template_id: template_id)
      end

      def combinations
        HostStatus::RenderingStatusCombination.where(template_id: template_id)
      end

      def refresh_global_statuses
        hosts = Host::Managed.joins(:rendering_status_combinations)
                             .where(rendering_status_combinations: { template_id: template_id })
        RefreshGlobalStatuses.call(hosts)
      end

      def update_combination
        raise NotImplementedError
      end

      def update_warnings
        raise NotImplementedError
      end
    end
  end
end
