class AuthSourceLdapsController < ApplicationController
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @auth_source_ldaps = resource_base.load
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
end
