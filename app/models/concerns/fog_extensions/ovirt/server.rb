module FogExtensions
  module Ovirt
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      attr_accessor :image_id

      # locked_with_refresh? is only needed until 1989e915ff9487fb5fbfd3dae1964db4c289cb1f is included in fog release (1.23)
      included do
        alias_method_chain :locked?, :refresh
      end

      def to_s
        name
      end

      def locked_with_refresh?
        @volumes = nil # force reload volumes
        locked_without_refresh?
      end

      def state
        status
      end

      def interfaces_attributes=(attrs); end

      def volumes_attributes=(attrs); end

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

      def select_nic(fog_nics, nic)
        fog_nics.detect {|fn| fn.network == nic.compute_attributes['network']} # grab any nic on the same network
      end
    end
  end
end
