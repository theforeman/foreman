module BelongsToProxies
  extend ActiveSupport::Concern

  included do
    class_attribute :registered_smart_proxies
    self.registered_smart_proxies ||= {}
    register_smart_proxies_from_plugins
  end

  delegate :registered_smart_proxies, :to => :class

  module ClassMethods
    def belongs_to_proxy(name, options)
      register_smart_proxy(name, options)
    end

    def register_smart_proxy(name, options)
      self.registered_smart_proxies = registered_smart_proxies.merge(name => options)
      belongs_to name, :class_name => 'SmartProxy'
      validates name, :proxy_features => { :feature => options[:feature], :required => options[:required] }
    end

    def register_smart_proxies_from_plugins
      my_smart_proxies_from_plugins.each do |name, options|
        register_smart_proxy(name, options)
      end
    end

    private

    def my_smart_proxies_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.smart_proxies(self) }.inject({}, :merge)
    end
  end
end
