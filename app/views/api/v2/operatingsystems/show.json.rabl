object @operatingsystem
attributes :id, :name, :major, :minor, :family, :release_name

child :media, :object_root => false do
  attributes :id, :name
end

child :architectures, :object_root => false do
  attributes :id, :name
end

child :ptables, :object_root => false do
  attributes :id, :name
end

child :config_templates, :object_root => false do
  attributes :name, :id
end

child :os_default_templates, :object_root => false do
  attributes :id, :config_template_id, :config_template_name, :template_kind_id, :template_kind_name
end
