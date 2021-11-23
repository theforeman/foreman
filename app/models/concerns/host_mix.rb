module HostMix
  extend ActiveSupport::Concern

  class_methods do
    def has_many_hosts(options = {})
      has_many :hosts, {:class_name => "Host::Managed"}.merge(options)
    end

    def belongs_to_host(options = {})
      belongs_to :host, {:class_name => "Host::Managed", :foreign_key => :host_id}.merge(options)
    end
  end
end
