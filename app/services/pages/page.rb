module Pages
  class Page < ViewItem
    attr_reader :url_hash, :view

    def initialize(url_hash, view, columns_count)
      @url_hash = url_hash
      @view = view
      super columns_count
    end

    def name
      "#{@url_hash[:controller]}/#{url_hash[:action]}".to_sym
    end
  end
end
