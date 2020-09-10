Foreman::Application.routes.draw do
  namespace :api, :defaults => {:format => 'json'} do
    # new v2 routes that point to v2
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'}, :apiv => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
      constraints(:id => /[^\/]+/) do
        resources :hosts, :except => [:new, :edit] do
          put :puppetrun, :on => :member, :to => 'puppet_hosts#puppetrun'
        end
      end
    end
  end
end
