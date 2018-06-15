module FogExtensions
  module Ovirt
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      attr_accessor :image_id

      def to_s
        name
      end

      def state
        status
      end

      def interfaces_attributes=(attrs)
      end

      def volumes_attributes=(attrs)
      end

      def poweroff
        service.vm_action(:id => id, :action => :shutdown)
      end

      def reset
        reboot
      end

      def vm_description
        _("%{cores} Cores and %{memory} memory") % {:cores => cores, :memory => number_to_human_size(memory.to_i)}
      end

      def select_nic(fog_nics, nic)
        fog_nics.detect {|fn| fn.network == nic.compute_attributes['network']} # grab any nic on the same network
      end
    end
  end
end
