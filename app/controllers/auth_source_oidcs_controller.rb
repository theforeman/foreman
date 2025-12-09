class AuthSourceOidcsController < ApplicationController
  include Foreman::Controller::Parameters::AuthSourceOidc

  before_action :find_resource, only: [:edit, :update, :destroy]

  def new
    @auth_source_oidc = AuthSourceOidc.new
  end

  def create
    @auth_source_oidc = AuthSourceOidc.new(auth_source_oidc_params)
    if @auth_source_oidc.save
      process_success success_redirect: auth_sources_path,
        success_msg: _("Successfully created OIDC authentication source %s. Please restart Foreman to activate it.") % @auth_source_oidc.name
    else
      process_error
    end
  end

  def edit
  end

  def update
    update_params = auth_source_oidc_params
    update_params = update_params.except(:oidc_client_secret) if update_params[:oidc_client_secret].blank?

    if @auth_source_oidc.update(update_params)
      process_success success_redirect: auth_sources_path,
        success_msg: _("Successfully updated OIDC authentication source %s. Please restart Foreman to apply changes.") % @auth_source_oidc.name
    else
      process_error
    end
  end

  def destroy
    if @auth_source_oidc.destroy
      process_success success_redirect: auth_sources_path,
        success_msg: _("Successfully deleted OIDC authentication source. Please restart Foreman to apply changes.")
    else
      process_error redirect: auth_sources_path
    end
  end

  private

  def controller_permission
    'authenticators'
  end
end
