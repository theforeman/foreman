module Host
  module Hostmix
    def has_many_hosts(options = {})
      has_many :hosts, {:class_name => "Host::Managed"}.merge(options)
    end

    def belongs_to_host(options = {})
      Foreman::Deprecation.deprecation_warning('1.17', 'Method belongs_to_host was renamed to belongs_to_host_managed')
      belongs_to_host_managed(options)
    end

    def belongs_to_host_base(options = {})
      belongs_to :host, {:class_name => "Host::Base", :foreign_key => :host_id}.merge(options)
    end

    def belongs_to_host_managed(options = {})
      belongs_to :host, {:class_name => "Host::Managed", :foreign_key => :host_id}.merge(options)
    end
  end
end
