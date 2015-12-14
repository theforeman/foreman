module Pages
  class Widget
    attr_reader :name, :partial

    def initialize(opts)
      opts[:name] ? @name = opts[:name] : fail("Widget should have a name")
      opts[:partial] ? @partial = opts[:partial] : fail("Widget should have a partial")
    end
  end
end
