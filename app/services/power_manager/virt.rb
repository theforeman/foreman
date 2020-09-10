require 'timeout'

module PowerManager
  class Virt < Base
    def initialize(opts = {})
      super(opts)
      begin
        Timeout.timeout(15) do
          @vm = host.compute_resource.find_vm_by_uuid(host.uuid)
        end
      rescue Timeout::Error
        raise Foreman::Exception.new(N_("Timeout has occurred while communicating with %s"), host.compute_resource)
      rescue => e
        Foreman::Logging.exception("Error has occurred while communicating to #{host.compute_resource}", e)
        raise Foreman::Exception.new(N_("Error has occurred while communicating with %{cr}: %{e}"), { :cr => host.compute_resource, :e => e })
      end
    end

    def virt_state
      # make sure we fetch latest vm status
      vm.reload
      vm.state
    end

    def state_output(result)
      result = result.to_s
      return 'on' if result =~ /started/i
      return 'off' if result =~ /paused/i
      translate_status(result) # unknown output
    end

    def default_action(action)
      vm.send(action)
    end

    def action_map
      super.deep_merge({
                         :on       => 'start',
                         :off      => 'stop',
                         :soft     => 'reboot',
                         :cycle    => 'reset',
                         :status   => {:action => :virt_state, :output => :state_output},
                         :state    => {:action => :virt_state, :output => :state_output},
                       })
    end

    private

    attr_reader :vm
  end
end
