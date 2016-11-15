module FogExtensions
  module RackspaceV2
    module Server
      extend ActiveSupport::Concern

      def vm_description
        flavor.name
      end

      def ip_addresses
        addresses.inject([]) { |all, (_, addrs)| all.unshift(*addrs.map { |a| a['addr'] }) }.select(&:present?)
      end
    end
  end
end
