class AuthSourceLdapsController < ApplicationController
  def index
    @auth_source_ldaps = AuthSourceLdap.all
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
      flash[:notice] = "Successfully created auth source ldap."
      redirect_to auth_source_ldaps_url
    else
      render :action => 'new'
    end
  end

  def edit
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
  end

  def update
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
    if @auth_source_ldap.update_attributes(params[:auth_source_ldap])
      flash[:notice] = "Successfully updated auth source ldap."
      redirect_to auth_source_ldaps_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @auth_source_ldap = AuthSourceLdap.find(params[:id])
    @auth_source_ldap.destroy
    flash[:notice] = "Successfully destroyed auth source ldap."
    redirect_to auth_source_ldaps_url
  end
end
