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
        else
          return FiltersHelperOverrides.search_path(type) if FiltersHelperOverrides.can_override?(type)
          resource_path = resource_path(type)
          resource_path.blank? ? "" : (resource_path + auto_complete_search_path)
      end
    end
  end

  def auto_complete_search_path
    '/auto_complete_search'
  end
end
