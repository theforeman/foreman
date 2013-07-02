class VirtPowerManager < PowerManager

  def initialize(opts = {})
    super(opts)
    begin
      timeout(15) do
        @vm = host.compute_resource.find_vm_by_uuid(host.uuid)
      end
    rescue Timeout::Error
      raise Foreman::Exception.new(N_("Timeout has occurred while communicating with %s"), host.compute_resource)
    rescue => e
      logger.warn "Error has occurred while communicating to #{host.compute_resource}: #{e}"
      logger.debug e.backtrace
      raise Foreman::Exception.new(N_("Error has occurred while communicating with %{cr}: %{e}"), { :cr => host.compute_resource, :e => e })
    end
  end

  def state
    # make sure we fetch latest vm status
    vm.reload
    vm.state
  end

  (SUPPORTED_ACTIONS - ['state']).each do |method|
    define_method method do
      vm.send(method.to_sym)
    end
  end

  private
  attr_reader :vm
end
