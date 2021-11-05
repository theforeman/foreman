class AuthSourceLdapsController < ApplicationController
  include Foreman::Controller::Parameters::AuthSourceLdap

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def new
    @auth_source_ldap = AuthSourceLdap.new
  end

  def create
    @auth_source_ldap = AuthSourceLdap.new(auth_source_ldap_params)
    if @auth_source_ldap.save
      process_success :success_redirect => auth_sources_path
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @auth_source_ldap.update(auth_source_ldap_params)
      process_success :success_redirect => auth_sources_path
    else
      process_error
    end
  end

  def destroy
    if @auth_source_ldap.destroy
      process_success :success_redirect => auth_sources_path
    else
      process_error :redirect => auth_sources_path
    end
  end

  def test_connection
    temp_auth_source_ldap = AuthSourceLdap.new(auth_source_ldap_params)
    msg = temp_auth_source_ldap.test_connection
    render :json => msg, :status => :ok
  rescue Foreman::Exception => exception
    Foreman::Logging.exception("Failed to connect to LDAP server", exception)
    render :json => {:message => exception.message}, :status => :unprocessable_entity
  end

  private

  def controller_permission
    'authenticators'
  end
end
