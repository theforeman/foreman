module Statistics
  class Base
    attr_reader :title, :count_by

    def initialize(options = {})
      @id       = options[:id]
      @title    = options[:title]
      @search   = options[:search]
      @url      = options[:url]
      @count_by = options[:count_by]
    end

    def calculate
      raise NotImplementedError, "Method 'calculate' method needs to be implemented"
    end

    def id
      @id || count_by.to_s
    end

    def url
      @url || "statistics/#{id}"
    end

    def search
      "/hosts?search=#{@search}"
    end

    def metadata
      {:id => id, :title => title, :url => url, :search => search}
    end
  end
end
