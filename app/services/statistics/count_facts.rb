module Statistics
  class CountFacts < Base
    attr_reader :unit

    def initialize(options = {})
      super(options)
      @count_by = @count_by.to_s
      @unit     = options[:unit]
    end

    def calculate
      FactValue.authorized(:view_facts).my_facts.count_each(count_by, :unit => unit)
    end
  end
end
