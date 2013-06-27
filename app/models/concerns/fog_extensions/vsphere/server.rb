module FogExtensions
  module Vsphere
    module Server

      def to_s
        name
      end

      def state
        power_state
      end

      def interfaces_attributes=(attrs); end

      def volumes_attributes=(attrs);  end

      def poweroff
        stop(:force => true)
      end

      def reset
        reboot(:force => true)
      end

    end
  end
end