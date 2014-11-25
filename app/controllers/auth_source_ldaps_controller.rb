class AuthSourceLdapsController < ApplicationController
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @auth_source_ldaps = resource_base.all
  end

  def new
    @auth_source_ldap = AuthSourceLdap.new
  end

  def create
    @auth_source_ldap = AuthSourceLdap.new(foreman_params)
    if @auth_source_ldap.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    # remove from hash :account_password if blank?
    params[:auth_source_ldap].except!(:account_password) if params[:auth_source_ldap][:account_password].blank?
    if @auth_source_ldap.update_attributes(foreman_params)
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
