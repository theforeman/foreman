module Pages
  class ViewItem
    attr_reader :tabs, :columns

    def initialize(column_count = 1)
      @columns = (0...column_count).map { Column.new }
      @tabs = {}.with_indifferent_access
    end

    def find_tab(tab_name)
      if @tabs[tab_name]
        @tabs[tab_name]
      elsif @tabs.values.empty?
        nil
      else
        @tabs.values.map { |item| item.find_tab tab_name }.compact.first
      end
    end

    def add_tab(opts)
      raise ::Foreman::Exception.new("Cannot add tab with no name") unless opts[:name]
      raise ::Foreman::Exception.new("Tab name #{opts[:name]} already exists") if find_tab(opts[:name])
      raise ::Foreman::Exception.new("This view item already has columns, no tabs can be added") if @columns.count > 1
      columns_count = opts[:columns_count] || 1
      priority = opts[:priority] || last_tab_priority - 1
      tab = Pages::Tab.new(opts[:name], priority, columns_count, opts[:layout])
      yield tab if block_given?
      @tabs[opts[:name]] = tab
    end

    def add_widget(opts)
      @columns[opts[:column] ? opts[:column] : 0] << Pages::Widget.new(opts)
    end

    def sorted_tabs
      @tabs.sort_by { |k,v| v.priority }.reverse.inject({}) do |result, ary|
        result[ary.first] = ary.last
        result
      end
    end

    private

    def last_tab_priority
      # We need a default priority value for the first tab if it is not specified
      @tabs.values.map(&:priority).min || 20
    end
  end
end
