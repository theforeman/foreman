module Pages
  class Manager
    class << self
      def add_page(url_hash, view, columns_count = 1)
        @pages ||= {}.with_indifferent_access
        page = Pages::Page.new(url_hash, view, columns_count)
        raise ArgumentError, "You are either trying to find non-existing view item or add a page with already existing name" if @pages[page.name]
        yield page if block_given?
        @pages[page.name] = page
      end

      def extend_page(url_hash)
        page = find_page(url_hash[:controller], url_hash[:action])
        yield page if block_given?
      end

      def extend_tab(url_hash, tab_name)
        page = find_page(url_hash[:controller], url_hash[:action])
        tab = page.find_tab tab_name
        if tab
          yield tab if block_given?
        else
          raise ::Foreman::Eception.new("No tab with name #{tab_name} on page #{page.name} was found")
        end
      end

      def load_pages
        Pages::Loader.load
      end

      def find_page(controller, action)
        find_page_by_name("#{controller}/#{action}".to_sym)
      end

      private

      def find_page_by_name(page_name)
        if @pages.nil? || @pages[page_name].nil?
          begin
            load_pages
          rescue ArgumentError => e
            raise ::ForemanException.new(e.message)
          end
        end
        @pages[page_name]
      end
    end
  end
end
