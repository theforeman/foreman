object @operatingsystem
attributes :id, :name, :major, :minor, :family, :release_name, :password_hash

child :media do
  attributes :id, :name
end

child :architectures do
  attributes :id, :name
end

child :ptables => :ptables do
  attributes :id, :name
end

child :provisioning_templates => :config_templates do
  attributes :name, :id
end

child :os_default_templates do
  attributes :id => :id, :provisioning_template_id => :config_template_id, :template_kind_id => :template_kind_id
end
