object @medium

attributes :id, :name, :path, :os_family, :created_at, :updated_at, :operatingsystem_ids

node do |medium|
  if medium.os_family == 'Solaris'
    attributes :media_path, :config_path, :image_path
  end
end
