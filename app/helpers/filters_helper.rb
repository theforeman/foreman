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
          return FiltersHelperOverrides.search_path(type) if FiltersHelperOverrides.can_override?(type)
          resource_path = resource_path(type)
          resource_path.nil? ? "" : resource_path + auto_complete_search_path
      end
    end
  end

  def auto_complete_search_path
    '/auto_complete_search'
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
