class PermissionsController < ApplicationController
  include FiltersHelper
  include TaxonomyHelper
  respond_to :js

  def index
    type = params[:resource_type].presence
    @permissions = Permission.where(:resource_type => type)
    @search_path = search_path(type)
    @granular = granular?(type)

    if @granular
      resource_class = Filter.get_resource_class(type)
      @show_organizations = show_organization_tab? && resource_class.allows_organization_filtering?
      @show_locations = show_location_tab? && resource_class.allows_location_filtering?
    end
  end

  private

  def granular?(type)
    Filter.new(:resource_type => type).granular?
  end
end
