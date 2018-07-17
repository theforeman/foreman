module InputResolver
  class FactInputResolver < Base
    # fact might not be present if it hasn't been uploaded yet, there's typo in name
    def ready?
      @scope.host && get_fact.present?
    end

    def resolved_value
      get_fact.value
    end

    private

    def get_fact
      @fact ||= @scope.host.fact_values.includes(:fact_name).find_by(:'fact_names.name' => @input.fact_name)
    end
  end
end
