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
  ctx.with_profile :reported_data, _('Reported data'), default: false do
    common_th_class = 'hidden-tablet hidden-xs'
    common_td_class = common_th_class + ' ellipsis'
    add_pagelet :hosts_table_column_header, key: :sockets, label: _('Sockets'), width: '5%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :sockets, callback: ->(host) { host.reported_data&.sockets }, class: common_td_class
    add_pagelet :hosts_table_column_header, key: :cores, label: _('Cores'), width: '5%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :cores, callback: ->(host) { host.reported_data&.cores }, class: common_td_class
    add_pagelet :hosts_table_column_header, key: :ram, label: _('RAM'), width: '5%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :ram, callback: ->(host) { humanize_bytes(host.reported_data&.ram, from: :mega) }, class: common_td_class
    add_pagelet :hosts_table_column_header, key: :boot_time, label: _('Boot time'), width: '10%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :boot_time, callback: ->(host) { date_time_relative(host.reported_data&.boot_time) }, class: common_td_class
    add_pagelet :hosts_table_column_header, key: :virtual, label: _('Virtual'), width: '5%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :virtual, callback: ->(host) { virtual?(host) }, class: common_td_class
    add_pagelet :hosts_table_column_header, key: :disks_total, label: _('Disks total space'), width: '8%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :disks_total, callback: ->(host) { humanize_bytes(host.reported_data&.disks_total) }, class: common_td_class
    add_pagelet :hosts_table_column_header, key: :kernel_version, label: _('Kernel version'), width: '12%', class: common_th_class
    add_pagelet :hosts_table_column_content, key: :kernel_version, callback: ->(host) { host.reported_data&.kernel_version }, class: common_td_class
  end
end
