class PermissionsController < ApplicationController
  include FiltersHelper
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

end
