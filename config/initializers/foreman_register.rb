Pagelets::Manager.with_key 'hosts/show' do |mgr|
  mgr.add_pagelet :main_tabs,
    name: 'Initial configuration',
    partial: 'hosts/init_config_tab',
    priority: 100
end

Foreman::SelectableColumns::Storage.define(:hosts) do
  common_th_class = 'hidden-tablet hidden-xs'
  common_td_class = common_th_class + ' ellipsis'
  category :general, default: true do
    column :name, th: { label: _('Name'), sortable: true, width: '25%' },
                  td: { class: 'ellipsis', callback: ->(host) { name_column(host) } }
    column :os_title, th: { label: _('Operating system'), sortable: true, width: '17%', class: 'hidden-xs' },
                      td: { class: 'hidden-xs ellipsis', callback: ->(host) { (icon(host.operatingsystem, size: "16x16") + " #{host.operatingsystem.to_label}").html_safe if host.operatingsystem } }
    column :model, th: { label: _('Model'), sortable: true, width: '10%', class: common_th_class },
                   td: { class: common_td_class, callback: ->(host) { host.compute_resource_or_model } }
    column :owner, th: { label: _('Owner'), sortable: true, width: '8%', class: common_th_class },
                   td: { class: common_td_class, callback: ->(host) { host_owner_column(host) } }
    column :hostgroup, th: { label: _('Host group'), sortable: true, width: '15%', class: common_th_class },
                       td: { class: common_th_class, callback: ->(host) { label_with_link host.hostgroup, 23, @hostgroup_authorizer } }
    column :last_report, th: { label: _('Last report'), sortable: true, default_sort: 'DESC', width: '10%', class: common_th_class },
                         td: { class: common_td_class, callback: ->(host) { last_report_column(host) } }
    column :comment, th: { label: _('Comment'), sortable: true, width: '7%', class: common_th_class },
                     td: { class: common_th_class + ' ca',
                           attr_callbacks: { title: ->(host) { host.comment&.truncate(255) } },
                           callback: ->(host) { icon_text('comment', '') unless host.comment.empty? } }
  end
end
