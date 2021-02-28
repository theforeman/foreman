Pagelets::Manager.with_key 'hosts/show' do |mgr|
  mgr.add_pagelet :main_tabs,
    name: 'Initial configuration',
    partial: 'hosts/init_config_tab',
    priority: 100
end
