module FogExtensions
  module Ovirt
    module Server

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

    end
  end
end