object @medium

extends "api/v2/media/base"

attributes :path, :os_family, :created_at, :updated_at

node do |medium|
  if medium.os_family == 'Solaris'
    attributes :media_path, :config_path, :image_path
  end
end
