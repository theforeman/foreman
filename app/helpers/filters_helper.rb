module FiltersHelper
  def search_path(type)
    if type.nil?
      ''
    else
      namespace_and_class = type.split('::')
      if namespace_and_class.size == 2
        plugin_filters_helper_class = class_eval "#{namespace_and_class[0]}::FiltersHelper" rescue nil
      end
      # This allows for engines to define their own classes without autocomplete and and autocomplete paths.
      # We assume that engine's namespace is only one level deep, i.e. EngineA::FiltersHelper
      # Note that we expect engine's FiltersHelper to contain class methods
      if !plugin_filters_helper_class.nil? && plugin_filters_helper_class.respond_to?(:search_path)
        return instance_eval { plugin_filters_helper_class.search_path(type) }
      end
      case type
        when 'Image'
          '' # images are nested resource for CR, we can't autocomplete
        when 'HostClass'
          '' # host classes is only used in API
        when 'Parameter'
          '' # parameter is only used in API
        else
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
