object @operatingsystem
attributes :id, :name, :major, :minor, :family, :release_name

child :media do
    attributes :id, :name, :path, :media_path, :config_path, :image_path, :os_family
end

child :architectures do
    attributes :id, :name
end

child :ptables do
    attributes :id, :name, :layout, :os_family
end

child :config_templates do
   attributes :id, :name, :template, :snippet, :template_kind
end