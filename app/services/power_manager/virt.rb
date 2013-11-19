module PowerManager
  class Virt < Base

    def initialize(opts = {})
      super(opts)
      begin
        timeout(15) do
          @vm = system.compute_resource.find_vm_by_uuid(system.uuid)
        end
      rescue Timeout::Error
        raise Foreman::Exception.new(N_("Timeout has occurred while communicating with %s"), system.compute_resource)
      rescue => e
        logger.warn "Error has occurred while communicating to #{system.compute_resource}: #{e}"
        logger.debug e.backtrace
        raise Foreman::Exception.new(N_("Error has occurred while communicating with %{cr}: %{e}"), { :cr => system.compute_resource, :e => e })
      end
    end

    def state
      # make sure we fetch latest vm status
      vm.reload
      vm.state
    end

    (SUPPORTED_ACTIONS - ['state', 'status']).each do |method|
      define_method method do
        vm.send(action_map[method.to_sym])
      end
    end

    private
    attr_reader :vm

    def action_map
      {
        :on       => 'start',
        :off      => 'stop',
        :soft     => 'reboot',
        :cycle    => 'reset',
        :status   => 'state',
        :start    => 'start',
        :stop     => 'stop',
        :poweroff => 'poweroff',
        :reset    => 'reset',
        :state    => 'state'
      }
    end
  end
end
