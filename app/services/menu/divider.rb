module Menu
  class Divider < Node
    def initialize(name, options={})
      @caption = options[:caption]
      super name
    end

    def authorized?
      true
    end
  end
end