class PermissionsController < ApplicationController
  respond_to :js

  def index
    type = params[:resource_type].blank? ? nil : params[:resource_type]
    @permissions = Permission.find_all_by_resource_type(type)
    @search_path = search_path(type)
    @granular = granular?(type)
  end

  private

  def granular?(type)
    Filter.new(:resource_type => type).granular?
  end

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
          send(type.pluralize.underscore + '_path') + '/auto_complete_search'
      end
    end

  end

end
