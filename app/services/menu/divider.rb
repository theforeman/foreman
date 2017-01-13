module Menu
  class Divider < Node
    def initialize(name, options = {})
      @caption = options[:caption]
      @parent = options.fetch(:parent, nil)
      super name
    end

    def authorized?
      true
    end

    # Node#content_hash for more info
    def content_hash
      hash = Digest::MD5.new()
      hash << super
      hash << @caption.to_s if @caption
      hash.hexdigest
    end
  end
end
