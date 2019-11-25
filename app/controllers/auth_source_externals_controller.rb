class AuthSourceExternalsController < ApplicationController
  include Foreman::Controller::Parameters::AuthSourceExternal

  before_action :find_resource, :only => [:edit, :update]

  def edit
  end

  def update
    if @auth_source_external.update(auth_source_external_params)
      process_success :success_redirect => auth_sources_path
    else
      process_error :redirect => auth_sources_path
    end
  end

  private

  def controller_permission
    'authenticators'
  end
end
