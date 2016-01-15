module DisableTurbolinks
  class Registry
    attr_reader :pages

    def initialize
      @pages ||= []
    end

    def include?(path_hash)
      @pages.include? "#{path_hash[:controller]}/#{path_hash[:action]}"
    end

    def has_path?(path)
      begin
        include? Rails.application.routes.recognize_path(path)
      rescue
        #if cannot detect route, just ignore it
        false
      end
    end

    def register(page_name)
      @pages << page_name unless @pages.include? page_name
    end
  end
end
