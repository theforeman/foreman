module FogExtensions
  module Ovirt
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      attr_accessor :image_id

      def state
        status
      end

      def interfaces_attributes=(attrs); end

      def volumes_attributes=(attrs);  end

      def poweroff
        service.vm_action(:id =>id, :action => :shutdown)
      end

      def reset
        poweroff
        start
      end

      def vm_description
        _("%{cores} Cores and %{memory} memory") % {:cores => cores, :memory => number_to_human_size(memory.to_i)}
      end

    end
  end
end
