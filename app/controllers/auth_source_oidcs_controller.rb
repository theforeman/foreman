class AuthSourceOidcsController < ApplicationController
  include Foreman::Controller::Parameters::AuthSourceOidc

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def new
    @auth_source_oidc = AuthSourceOidc.new
  end

  def create
    @auth_source_oidc = AuthSourceOidc.new(auth_source_oidc_params)
    if @auth_source_oidc.save
      process_success :success_redirect => auth_sources_path
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @auth_source_oidc.update(auth_source_oidc_params)
      process_success :success_redirect => auth_sources_path
    else
      process_error
    end
  end

  def destroy
    if @auth_source_oidc.destroy
      process_success :success_redirect => auth_sources_path
    else
      process_error :redirect => auth_sources_path
    end
  end

  def test_connection
    auth_source = test_auth_source
    render :json => auth_source.test_connection, :status => :ok
  rescue Foreman::Exception => exception
    Foreman::Logging.exception('Failed to connect to OpenID Connect provider', exception)
    render :json => { :message => exception.message }, :status => :unprocessable_entity
  end

  private

  def test_auth_source
    existing = AuthSourceOidc.with_taxonomy_scope.find_by(:id => params.dig(:auth_source_oidc, :id))
    attributes = auth_source_oidc_params
    attributes = attributes.except(:oidc_client_secret) if attributes[:oidc_client_secret].blank?
    (existing || AuthSourceOidc.new).tap { |auth_source| auth_source.assign_attributes(attributes) }
  end

  def controller_permission
    'authenticators'
  end

  def action_permission
    return super unless params[:action] == 'test_connection'

    params.dig(:auth_source_oidc, :id).present? ? 'edit' : 'create'
  end

  def resource_scope(...)
    super.merge(AuthSourceOidc.with_taxonomy_scope)
  end
end
