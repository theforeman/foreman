module Menu
  class Submenu
    attr_reader :display

    def initialize(display, sub_items)
      @display        = display
      @sub_items      = sub_items
    end

    def sub_items
      @sub_items.map{|sub_item| sub_item if sub_item.authorized?}.compact
    end

    def authorized?
      true
    end

  end
end
