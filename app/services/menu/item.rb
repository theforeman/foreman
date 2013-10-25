module Menu
  class Item
    attr_reader :display, :url_hash

    def initialize(display, url_hash)
      @display        = display
      @url_hash       = url_hash
    end

    def authorized?
      User.current.allowed_to?({
        :controller => @url_hash[:controller].to_s.gsub(/::/, "_").underscore,
        :action => @url_hash[:action]
      }) rescue false
    end

  end
end
