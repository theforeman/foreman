Pagelets::Manager.with_key 'hosts/show' do |mgr|
  mgr.add_pagelet :main_tabs,
    name: 'Initial configuration',
    partial: 'hosts/init_config_tab',
    priority: 100
end

Pagelets::Manager.with_key 'hosts/_list' do |ctx|
  ctx.with_profile :general, _('General'), default: true do
    common_th_class = 'hidden-tablet hidden-xs'
    common_td_class = common_th_class + ' ellipsis'
    add_pagelet :hosts_table_column_header, key: :name, label: _('Name'), sortable: true, width: '25%'
    add_pagelet :hosts_table_column_content, key: :name, class: 'ellipsis', callback: ->(host) { name_column(host) }
    add_pagelet :hosts_table_column_header, key: :os_title, label: _('Operating system'), sortable: true, width: '17%', class: 'hidden-xs'
    add_pagelet :hosts_table_column_content, key: :os_title, class: 'hidden-xs ellipsis', callback: ->(host) { (icon(host.operatingsystem, size: "16x16") + " #{host.operatingsystem.to_label}").html_safe if host.operatingsystem }
    add_pagelet :hosts_table_column_header, key: :model, label: _('Model'), sortable: true, width: '10%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :model, class: common_td_class, callback: ->(host) { host.compute_resource_or_model }
    add_pagelet :hosts_table_column_header, key: :owner, label: _('Owner'), sortable: true, width: '8%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :owner, class: common_td_class, callback: ->(host) { host_owner_column(host) }
    add_pagelet :hosts_table_column_header, key: :hostgroup, label: _('Host group'), sortable: true, width: '15%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :hostgroup, class: common_th_class, callback: ->(host) { label_with_link host.hostgroup, 23, @hostgroup_authorizer }
    add_pagelet :hosts_table_column_header, key: :last_report, label: _('Last report'), sortable: true, default_sort: 'DESC', width: '10%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :last_report, class: common_td_class, callback: ->(host) { last_report_column(host) }
    add_pagelet :hosts_table_column_header, key: :comment, label: _('Comment'), sortable: true, width: '7%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :comment, class: common_th_class + ' ca', attr_callbacks: { title: ->(host) { host.comment&.truncate(255) } }, callback: ->(host) { icon_text('comment', '') unless host.comment.empty? }
  end
end
