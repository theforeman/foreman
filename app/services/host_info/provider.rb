module HostInfo
  class Provider
    def initialize(host)
      @host = host
    end

    # The method should not accept any parameters and return
    # a Hash object that will be merged into the resulting info hash.
    # Host model is accessible through :host attribute.
    # The structure of the recommended hash is as follows:
    # {
    #   'parameters' => {
    #     'param1' => 'value1'
    #   }
    # }
    def host_info
      throw 'Provider is not implemented'
    end

    private

    attr_reader :host
  end
end
