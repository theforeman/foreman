object @operatingsystem
attributes :id, :name, :major, :minor, :family, :release_name

child :media do
    extends "api/v1/media/show"
end

child :architectures do
    extends "api/v1/architectures/show"
end

child :ptables do
    attributes :id, :name, :layout, :os_family
end

child :config_templates do
   attributes :id, :name, :template, :snippet, :template_kind
end