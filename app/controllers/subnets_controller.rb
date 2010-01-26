class SubnetsController < ApplicationController
  layout 'standard'

  active_scaffold :subnet do |config|
    config.columns = [:domain, :name, :number, :mask, :ranges, :dhcp, :vlanid]
    config.create.columns = [:domain, :name, :number, :mask, :ranges, :dhcp, :priority, :vlanid]
    config.columns[:domain].label = "Site"
    config.columns[:vlanid].label = "VLAN id"
    columns[:dhcp].label = "DHCP Server"
    columns[:ranges].label = "Address ranges"
    config.columns[:ranges].description = "A list of comma separated single IPs or start-end couples."
    columns[:mask].label = "Netmask"
    config.columns[:domain].form_ui  = :select
    config.columns[:dhcp].form_ui    = :select
    list.columns.exclude :created_at, :updated_at
    list.sorting = {:domain => 'DESC' }
    columns['domain'].sort_by :sql

    # Deletes require a page update so as to show error messsages
    config.delete.link.inline = false

    config.nested.add_link "Hosts", [:hosts]
  end
end
