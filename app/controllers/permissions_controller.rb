class PermissionsController < ApplicationController
  include FiltersHelper
  include TaxonomyHelper

  def show_resource_types_with_translations
    resources = Permission.resources
    render :json => {
      :resource_types => resources.map do |resource|
                           resource_class = Filter.get_resource_class(resource)
                           granular = granular?(resource)
                           show_organizations = false
                           show_locations = false
                           if granular
                             show_organizations = show_organization_tab? && resource_class.allows_organization_filtering?
                             show_locations = show_location_tab? && resource_class.allows_location_filtering?
                           end
                           {
                             :translation => _(resource_class.try(:humanize_class_name) || resource),
                             :name => resource,
                             :granular => granular,
                             :search_path => search_path(resource),
                             :show_organizations => show_organizations,
                             :show_locations => show_locations,
                           }
                         end}
  end

  private

  def granular?(type)
    Filter.new(:resource_type => type).granular?
  end

  def action_permission
    case params[:action]
      when 'show_resource_types_with_translations'
        'view'
      else
        super
    end
  end
end
