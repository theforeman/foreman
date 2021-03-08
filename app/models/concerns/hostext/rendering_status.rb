module Hostext
  module RenderingStatus
    extend ActiveSupport::Concern

    included do
      has_one :rendering_status, foreign_key: :host_id,
                                 inverse_of: :host,
                                 class_name: 'HostStatus::RenderingStatus'

      has_many :rendering_status_combinations, through: :rendering_status,
                                               source: :combinations,
                                               dependent: :destroy

      after_save :destroy_stale_rendering_status_combinations, if: :saved_change_to_rendering_status_combinations?

      def destroy_stale_rendering_status_combinations
        if operatingsystem_id
          template_ids = find_templates.map(&:id)

          rendering_status_combinations.where.not(template_id: template_ids).destroy_all
        else
          rendering_status_combinations.destroy_all
        end
      end

      def host_statuses_with_rendering_status
        host_statuses | [rendering_status].compact
      end

      private

      def saved_change_to_rendering_status_combinations?
        attrs = [
          :organization_id,
          :location_id,
          :operatingsystem_id,
          :environment_id,
          :hostgroup_id,
        ]

        (saved_changes.keys & attrs).any?
      end
    end
  end
end
