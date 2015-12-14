module Pages
  class Column
    attr_reader :widgets

    def initialize
      @widgets = []
    end

    def find_widget(widget_name)
      @widgets.find { |w| w.name == widget_name.to_sym }
    end

    def <<(widget)
      @widgets << widget
    end
  end
end
