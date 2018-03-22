module Menu
  class Toggle < Node
    attr_accessor :icon
    def initialize(name, caption, icon)
      @caption = caption
      @icon = icon || ""
      super name.to_sym
    end

    def authorized?
      true
    end
  end
end
