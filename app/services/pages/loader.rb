module Pages
  class Loader
    def self.load
      Pages::Manager.add_page({ :controller => :smart_proxies, :action => :show }, "smart_proxies/show") do |page|
        page.add_tab(:name => :overview, :columns_count =>  2, :layout => "smart_proxies/tabs/overview") do |tab|
          tab.add_widget :name => :details, :partial => 'smart_proxies/widgets/details', :column => 0
        end
        page.add_tab(:name => :services, :columns_count => 2, :layout => "smart_proxies/tabs/services")
      end
    end
  end
end
