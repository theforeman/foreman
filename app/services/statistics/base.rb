module Statistics
  class Base
    attr_reader :title, :count_by, :url

    def initialize(options = {})
      @id = options[:id]
      @title = options[:title]
      @search = options[:search]
      @count_by = options[:count_by]
      @organization_id = options[:organization_id]
      @location_id = options[:location_id]
      @url = options[:url] || build_url
    end

    def calculate
      raise NotImplementedError, "Method 'calculate' method needs to be implemented"
    end

    def id
      @id || count_by.to_s
    end

    def search
      "/hosts?search=#{@search}"
    end

    def metadata
      {:id => id, :title => title, :url => url, :search => search}
    end

    private

    def build_url
      Rails.application.routes.url_helpers.url_for({ :controller => 'statistics', :action => 'show', :id => id, :only_path => true, :location_id => @location_id, :organization_id => @organization_id })
    end
  end
end
