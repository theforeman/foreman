class AuthSourceExternalController < ApplicationController
  include Foreman::Controller::Parameters::AuthSourceExternal

  before_action :find_resource, :only => [:show, :update]

  def index
    @auth_source_external = resource_base_search_and_page.all
  end

  def edit
  end

  def update
    if @auth_source_external.update_attributes(auth_source_external_params)
      process_success
    else
      process_error
    end
  end

  private

  def controller_permission
    'authenticators'
  end
end