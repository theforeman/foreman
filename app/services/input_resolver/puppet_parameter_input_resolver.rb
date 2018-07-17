module InputResolver
  class PuppetParameterInputResolver < Base
    def ready?
      @scope.host &&
        get_enc.key?(@input.puppet_class_name) &&
        get_enc[@input.puppet_class_name].is_a?(Hash) &&
        get_enc[@input.puppet_class_name].key?(@input.puppet_parameter_name)
    end

    def resolved_value
      get_enc[@input.puppet_class_name][@input.puppet_parameter_name]
    end

    private

    def get_enc
      @enc ||= HostInfoProviders::PuppetInfo.new(@scope.host).puppetclass_parameters
    end
  end
end
