module Menu
  class Divider < Node
    def initialize(name, options = {})
      @caption = options[:caption]
      @parent = options.fetch(:parent, nil)
      super name
    end

    def to_hash
      {type: :divider, name: @caption}
    end

    def authorized?
      true
    end
  end
end
