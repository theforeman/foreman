module FiltersHelper
  def search_path(type)
    if type.nil?
      ''
    else
      case type
        when 'Image'
          '' # images are nested resource for CR, we can't autocomplete
        when 'HostClass'
          '' # host classes is only used in API
        when 'Parameter'
          '' # parameter is only used in API
        else
          resource_path(type) + '/auto_complete_search'
      end
    end
  end

  def resource_path(type)
    return '' if type.nil?

    path = type.pluralize.underscore + "_path"
    prefix, suffix = path.split('/', 2)
    if path.include?("/") && Rails.application.routes.mounted_helpers.method_defined?(prefix)
      # handle mounted engines
      engine = send(prefix)
      engine.send(suffix) if engine.respond_to?(suffix)
    else
      path = path.tr("/", "_")
      send(path) if respond_to?(path)
    end
  end
end
