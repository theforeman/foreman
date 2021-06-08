module Foreman
  module Rendering
    class UnsafemodeErrorSubscriber < ::Foreman::BaseSubscriber
      def call(event)
        host_id = event.payload[:host_id]
        template_id = event.payload[:template_id]

        return unless template_id && host_id

        # update combination
        combination = HostStatus::RenderingStatusCombination.find_or_initialize_by(host_id: host_id, template_id: template_id)
        combination.update!(unsafemode_status: HostStatus::RenderingStatusCombination::ERROR)

        # add warnings
        HostStatus::RenderingStatusCombination.where(template_id: template_id)
                                              .where(unsafemode_status: HostStatus::RenderingStatusCombination::OK)
                                              .update_all(unsafemode_status: HostStatus::RenderingStatusCombination::WARN)

        # refresh global statuses
        hosts = Host::Managed.joins(:rendering_status_combinations)
                             .where(rendering_status_combinations: { template_id: template_id })
        RefreshGlobalStatuses.call(hosts)
      end
    end
  end
end
