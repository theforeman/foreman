module FogExtensions
  module Xenserver
    module Server

      @display_tmp = nil

      def to_s
        name
      end

      def nics_attributes=(attrs); end

      def volumes_attributes=(attrs); end

      # Libvirt expect units in KB, while we use bytes
      def memory
        attributes[:memory_size].to_i * 1024
      end

      def memory= mem
        attributes[:memory_size] = mem.to_i / 1024 if mem
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
      
      def display2
        logger.info("nieeeeeeeeeeeeeeeeeee")
        return @display_tmp if @display_tmp != nil
        console = service.consoles.find {|c| c.__vm == reference && c.protocol == rtp}
        raise "No console found" unless console != nil
        @display_tmp = {
          :port => 1789
        }
        return @display_tmp
      end

    end
  end
end
