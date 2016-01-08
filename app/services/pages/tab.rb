module Pages
  class Tab < ViewItem
    attr_reader :name, :priority, :layout

    def initialize(name, priority, columns_count, layout = nil)
      @name = name
      @priority = priority
      @layout = layout
      super columns_count
    end

    def snake_name
      @name.to_s.gsub(/\s/, "_").underscore
    end
  end
end
