module Menu
  class Toggle < Node
    def initialize(name, caption)
      @caption = caption
      super name.to_sym
    end

    def authorized?
      true
    end
  end
end