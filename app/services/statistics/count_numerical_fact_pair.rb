module Statistics
  class CountNumericalFactPair < Base
    attr_reader :total, :used

    def initialize(options = {})
      super(options)
      raise(ArgumentError, 'Must provide :count_by option') if @count_by.empty?
      @count_by = @count_by.to_s
      @total    = options[:total] || 'size'
      @used     = options[:used]  || 'free'
    end

    def calculate
      mem_size = FactValue.authorized(:view_facts).my_facts.mem_average(total_name)
      mem_free = FactValue.authorized(:view_facts).my_facts.mem_average(used_name)

      [
        {
          :label => _('free memory'),
          :data => mem_free
        },
        {
          :label => _('used memory'),
          :data => (mem_size - mem_free).round(2)
        }
      ]
    end

    private

    def total_name
      count_by + total
    end

    def used_name
      count_by + used
    end
  end
end
