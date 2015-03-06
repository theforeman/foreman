require 'timeout'

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

  def test_connection
    result = {}
    begin
      Timeout::timeout(10) do
        temp_auth_source_ldap = AuthSourceLdap.new(params[:auth_source_ldap])
        temp_auth_source_ldap.ldap_con.valid_user?("")
      end
      result[:success] = true
      result[:message] = _("Connection to LDAP Server Successful !!")
    rescue => exception
      result[:success] = false
      result[:error_class] = exception.class.name
      result[:message] = _(exception.message)
    end
    render :json => result
  end

  def edit
  end

  def update
    # remove from hash :account_password if blank?
    params[:auth_source_ldap].except!(:account_password) if params[:auth_source_ldap][:account_password].blank?
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
end
