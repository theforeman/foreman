module BelongsToProxyHostnames
  extend ActiveSupport::Concern
  module ClassMethods
    def belongs_to_proxy_hostname(name, options)
      register_smart_proxy_hostname(name, options)
    end

    def register_smart_proxy_hostname(name, options)
      self.registered_smart_proxies = registered_smart_proxies.merge(name => options)
      belongs_to name, :class_name => 'Hostname'
      validates name, :proxy_features => { :feature => options[:feature] }
    end
  end
end
