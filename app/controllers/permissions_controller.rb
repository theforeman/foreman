class PermissionsController < ApplicationController
  respond_to :js

  def index
    type = params[:resource_type].blank? ? nil : params[:resource_type]
    @permissions = Permission.find_all_by_resource_type(type)
  end

end
