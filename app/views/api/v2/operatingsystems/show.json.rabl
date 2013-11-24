object @operatingsystem
attributes :id, :name, :major, :minor, :family, :release_name

child :media do
  attributes :id, :name
end

child :architectures do
  attributes :id, :name
end

child :ptables do
  attributes :id, :name
end

child :config_templates do
  attributes :name, :id
end

child :os_default_templates do
  attributes :id, :config_template_id, :config_template_name, :template_kind_id, :template_kind_name
end
