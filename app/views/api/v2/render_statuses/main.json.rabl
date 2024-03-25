object @render_status

extends "api/v2/render_statuses/base"

attributes :safemode, :success, :created_at, :updated_at

child :host do
  attributes :id, :name
  node :path do |host|
    path = host_details_page_path(host)
    User.current.allowed_to?(path) ? path : nil
  end
end

child :hostgroup do
  attributes :id, :name
  node :path do |hostgroup|
    path = edit_hostgroup_path(hostgroup)
    User.current.allowed_to?(path) ? path : nil
  end
end

child :provisioning_template do
  attributes :id, :name
  node :path do |provisioning_template|
    path = edit_provisioning_template_path(provisioning_template)
    User.current.allowed_to?(path) ? path : nil
  end
end
