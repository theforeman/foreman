module InputResolver
  class VariableInputResolver < Base
    def ready?
      @scope&.host&.params&.key?(@input.variable_name)
    end

    def resolved_value
      @scope.host.params[@input.variable_name]
    end
  end
end
