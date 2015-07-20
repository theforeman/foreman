require 'host_aspects/host_aspects'

HostAspects.register_configuration(:puppet_aspect) do
  extend_model :puppet_aspect_extensions
  add_helper :puppet_aspect_helper
end
