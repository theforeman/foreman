object @medium

attributes :id, :name, :path

node do |medium|
  if medium.os_family == 'Solaris'
    attributes :media_path, :config_path, :image_path
  end
end
