module Menu
  class Toggle < Node
    def initialize(name, caption)
      @caption = caption
      super name.to_sym
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
