class AuthSourceLdapsController < ApplicationController
  def index
    @auth_source_ldaps = AuthSourceLdap.all
    respond_to do |format|
      format.html { }
      format.json { render :json => @auth_source_ldaps }
    end
  end

  def show
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
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
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
  end

  def update
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
    if @auth_source_ldap.update_attributes(params[:auth_source_ldap])
      process_success
    else
      process_error
    end
  end

  def destroy
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
    if @auth_source_ldap.destroy
      process_success
    else
      process_error
    end

  end
end
