module FogExtensions
  module Fogdocker
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      def state
        state_running ? "Running" :"Stopped"
      end

      def command
        c=[]
        c += entrypoint if entrypoint.any?
        c += cmd if cmd.any?
        c.join(' ')
      end

      def poweroff
        service.vm_action(:id =>id, :action => :kill)
      end

      def reset
        poweroff
        start
      end

      def vm_description
        _("%{cores} Cores and %{memory} memory") % {:cores => cpus, :memory => number_to_human_size(memory.to_i)}
      end

    end
  end
end