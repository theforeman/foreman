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
          send(type.pluralize.underscore + '_path') + '/auto_complete_search'
      end
    end
  end
end
