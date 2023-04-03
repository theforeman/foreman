Pagelets::Manager.with_key 'hosts/show' do |mgr|
  mgr.add_pagelet :main_tabs,
    name: 'Initial configuration',
    partial: 'hosts/init_config_tab',
    priority: 100
end

Pagelets::Manager.with_key 'hosts/_list' do |ctx|
  ctx.with_profile :general, _('General'), default: true do
    common_class = 'hidden-tablet hidden-xs ellipsis'
    add_pagelet :hosts_table_column_header, key: :power_status, label: _('Power'), sortable: false, width: '80px', class: 'ca hidden-xs',
                export_data: CsvExporter::ExportDefinition.new(:power_status, callback: ->(host) { PowerManager::PowerStatus.safe_power_state(host)[:state] })
    add_pagelet :hosts_table_column_content, key: :power_status, class: 'ca hidden-xs', callback: ->(host) { react_component('PowerStatus', id: host.id, url: power_api_host_path(host)) }
    add_pagelet :hosts_table_column_header, key: :name, label: _('Name'), sortable: true, width: '24%', locked: true
    add_pagelet :hosts_table_column_content, key: :name, callback: ->(host) { name_column(host) }, locked: true, class: 'ellipsis'
    add_pagelet :hosts_table_column_header, key: :os_title, label: _('OS'), sortable: true, width: '17%', attr_callbacks: { title: ->(host) { _('Operating system') } }, export_key: 'operatingsystem', class: common_class
    add_pagelet :hosts_table_column_content, key: :os_title, callback: ->(host) { (icon(host.operatingsystem, size: "16x16") + " #{host.operatingsystem.to_label}").html_safe if host.operatingsystem }, class: common_class
    add_pagelet :hosts_table_column_header, key: :owner, label: _('Owner'), sortable: true, width: '8%', class: common_class
    add_pagelet :hosts_table_column_content, key: :owner, callback: ->(host) { host_owner_column(host) }, class: common_class
    add_pagelet :hosts_table_column_header, key: :hostgroup, label: _('Host group'), sortable: true, width: '15%', class: common_class
    add_pagelet :hosts_table_column_content, key: :hostgroup, callback: ->(host) { label_with_link host.hostgroup, 23, @hostgroup_authorizer }, class: common_class
    add_pagelet :hosts_table_column_header, key: :boot_time, label: _('Boot time'), sortable: true, width: '10%', export_key: 'reported_data.boot_time', class: common_class
    add_pagelet :hosts_table_column_content, key: :boot_time, callback: ->(host) { date_time_unless_empty(host.reported_data&.boot_time) }, class: common_class
    add_pagelet :hosts_table_column_header, key: :last_report, label: _('Last report'), sortable: true, default_sort: 'DESC', width: '10%', class: common_class
    add_pagelet :hosts_table_column_content, key: :last_report, callback: ->(host) { last_report_column(host) }, class: common_class
    add_pagelet :hosts_table_column_header, key: :comment, label: _('Comment'), sortable: true, width: '7%', class: common_class
    add_pagelet :hosts_table_column_content, key: :comment, class: common_class + ' ca', attr_callbacks: { title: ->(host) { h host.comment&.truncate(255) } }, callback: ->(host) { icon_text('comment', '') unless host.comment.empty? }
  end
  ctx.with_profile :network_data, _('Network'), default: false do
    common_class = 'hidden-tablet hidden-xs ellipsis'
    add_pagelet :hosts_table_column_header, key: :ip, label: _('IPv4'), sortable: true, width: '10%', attr_callbacks: { title: ->(host) { _('IPv4 address') } }, priority: 200, class: common_class
    add_pagelet :hosts_table_column_content, key: :ip, callback: ->(host) { host.ip }, priority: 200, class: common_class
    add_pagelet :hosts_table_column_header, key: :ip6, label: _('IPv6'), sortable: true, width: '13%', attr_callbacks: { title: ->(host) { _('IPv6 address') } }, priority: 200, class: common_class
    add_pagelet :hosts_table_column_content, key: :ip6, callback: ->(host) { host.ip6 }, priority: 200, class: common_class
    add_pagelet :hosts_table_column_header, key: :mac, label: _('MAC'), sortable: true, width: '10%', attr_callbacks: { title: ->(host) { _('MAC address') } }, priority: 200, class: common_class
    add_pagelet :hosts_table_column_content, key: :mac, callback: ->(host) { host.mac }, priority: 200, class: common_class
  end
  ctx.with_profile :reported_data, _('Reported data'), default: false do
    common_class = 'hidden-tablet hidden-xs ellipsis'
    add_pagelet :hosts_table_column_header, key: :model, label: _('Model'), sortable: true, width: '10%', export_key: 'compute_resource_or_model', class: common_class
    add_pagelet :hosts_table_column_content, key: :model, callback: ->(host) { host.compute_resource_or_model }, class: common_class
    add_pagelet :hosts_table_column_header, key: :sockets, label: _('Sockets'), width: '5%', export_key: 'reported_data.sockets', class: common_class
    add_pagelet :hosts_table_column_content, key: :sockets, callback: ->(host) { host.reported_data&.sockets }, class: common_class
    add_pagelet :hosts_table_column_header, key: :cores, label: _('Cores'), width: '5%', export_key: 'reported_data.cores', class: common_class
    add_pagelet :hosts_table_column_content, key: :cores, callback: ->(host) { host.reported_data&.cores }, class: common_class
    add_pagelet :hosts_table_column_header, key: :ram, label: _('RAM'), width: '5%', export_key: 'reported_data.ram', class: common_class
    add_pagelet :hosts_table_column_content, key: :ram, callback: ->(host) { humanize_bytes(host.reported_data&.ram, from: :mega) }, class: common_class
    add_pagelet :hosts_table_column_header, key: :virtual, label: _('Virtual'), width: '5%', class: common_class
    add_pagelet :hosts_table_column_content, key: :virtual, callback: ->(host) { virtual?(host) }, class: common_class
    add_pagelet :hosts_table_column_header, key: :disks_total, label: _('Disks space'), width: '8%', attr_callbacks: { title: ->(host) { _('Disks total space') } }, export_key: 'reported_data.disks_total', class: common_class
    add_pagelet :hosts_table_column_content, key: :disks_total, callback: ->(host) { humanize_bytes(host.reported_data&.disks_total) }, class: common_class
    add_pagelet :hosts_table_column_header, key: :kernel_version, label: _('Kernel version'), width: '12%', export_key: 'reported_data.kernel_version', class: common_class
    add_pagelet :hosts_table_column_content, key: :kernel_version, callback: ->(host) { host.reported_data&.kernel_version }, class: common_class
    add_pagelet :hosts_table_column_header, key: :bios_vendor, label: _('BIOS vendor'), width: '8%', export_key: 'reported_data.bios_vendor', class: common_class
    add_pagelet :hosts_table_column_content, key: :bios_vendor, callback: ->(host) { host.reported_data&.bios_vendor }, class: common_class
    add_pagelet :hosts_table_column_header, key: :bios_release_date, label: _('BIOS release date'), width: '10%', export_key: 'reported_data.bios_release_date', class: common_class
    add_pagelet :hosts_table_column_content, key: :bios_release_date, callback: ->(host) { host.reported_data&.bios_release_date }, class: common_class
    add_pagelet :hosts_table_column_header, key: :bios_version, label: _('BIOS version'), width: '12%', export_key: 'reported_data.bios_version', class: common_class
    add_pagelet :hosts_table_column_content, key: :bios_version, callback: ->(host) { host.reported_data&.bios_version }, class: common_class
  end
end
