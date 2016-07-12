class AuthSourceLdapsController < ApplicationController
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @auth_source_ldaps = resource_base.all
  end

  def new
    @auth_source_ldap = AuthSourceLdap.new
  end

  def create
    @auth_source_ldap = AuthSourceLdap.new(params[:auth_source_ldap])
    if @auth_source_ldap.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @auth_source_ldap.update_attributes(params[:auth_source_ldap])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @auth_source_ldap.destroy
      process_success
    else
      process_error
    end
  end

  def test_connection
    temp_auth_source_ldap = AuthSourceLdap.new(params[:auth_source_ldap])
    msg = temp_auth_source_ldap.test_connection
    render :json => msg, :status => :ok
  rescue Foreman::Exception => exception
    Foreman::Logging.exception("Failed to connect to LDAP server", exception)
    render :json => {:message => exception.message}, :status => :unprocessable_entity
  end
end
