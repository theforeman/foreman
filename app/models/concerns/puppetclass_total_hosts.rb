module PuppetclassTotalHosts

  module Indirect
    extend ActiveSupport::Concern

    included do
      #updates counters for all puppetclasses affected indirectly
      def update_puppetclasses_total_hosts(relation = nil)
        if self.is_a?(Hostgroup)
          config_groups.each(&:update_puppetclasses_total_hosts) if config_groups.present?
          parent.update_puppetclasses_total_hosts unless is_root?
        end
        puppetclasses.each(&:update_total_hosts) if puppetclasses.present?
      end

    end
  end

  module JoinTable
    extend ActiveSupport::Concern

    included do
      after_save :update_total_hosts
      after_destroy :update_total_hosts

      def update_total_hosts
        puppetclass.update_total_hosts
      end
    end
  end

end
