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

    send(type.pluralize.underscore + '_path')
  end
end
