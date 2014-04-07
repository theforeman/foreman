module FogExtensions
  module Xenserver
    module Server

      @display_tmp = nil

      def to_s
        name
      end

      def nics_attributes=(attrs); end

      def volumes_attributes=(attrs); end

      def memory_min
        memory_static_min.to_i
      end

      def memory_max
        memory_static_max.to_i
      end
      
      def memory
        memory_static_max.to_i
      end

      def reset
        reboot
      end

      def ready?
        running?
      end
      
      def mac
        vifs.first.mac
      end

      def state
       power_state
      end

      def custom_template_name
        template_name
      end

      def builtin_template_name
        template_name
      end

    end
  end
end
