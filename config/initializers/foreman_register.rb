Pagelets::Manager.with_key 'hosts/show' do |mgr|
  mgr.add_pagelet :main_tabs,
    name: 'Registration Tab',
    partial: 'hosts/registration_tab',
    priority: 100,
    onlyif: proc { |host, ctx| host.managed? }
end

Facets.register(ForemanRegister::RegistrationFacet, :registration_facet) do
  set_dependent_action :destroy
end
