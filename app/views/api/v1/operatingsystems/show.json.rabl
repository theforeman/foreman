object @operatingsystem
attributes :id, :name, :major, :minor, :family, :release_name, :type

child :media do
  extends "api/v1/media/show"
end

child :architectures do
  extends "api/v1/architectures/show"
end

child :ptables do
  extends "api/v1/ptables/show"
end


child :config_templates do
  extends "api/v1/config_templates/show"
end

child :os_default_templates do
  attributes :id, :config_template_id, :template_kind_id, :operating_system_id
end
