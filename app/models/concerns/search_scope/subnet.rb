module SearchScope
  module Subnet
    extend ActiveSupport::Concern

    included do
      scoped_search :on => [:name, :network, :mask, :gateway, :dns_primary, :dns_secondary,
                            :vlanid, :ipam, :boot_mode], :complete_value => true
      scoped_search :in => :domains, :on => :name, :rename => :domain, :complete_value => true
    end
  end
end

