object @operatingsystem

extends "api/v2/operatingsystems/main"

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
