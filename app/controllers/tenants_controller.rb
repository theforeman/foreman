class TenantsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    begin
      # TODO: Get the resource groups that belong to the current user
      tenants = User.current.admin? ? Tenant : Tenant
      values = tenants.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = tenants.search_for ""
    end

    respond_to do |format|
      format.html do
        @tenants = values.paginate :page => params[:page]
      end
    end
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(params[:tenant])

    if @tenant.save
      process_success
    else
      process_error
    end
  end

  def edit
    @tenant = Tenant.find(params[:tenant])
  end

  def update
    if @tenant.update_attributes(params[:tenant])
      process_success
    else
      process_error
    end
  end

  def destroy
    @tenant = Tenant.find(params[:id])

    if @tenant.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_tenant
    @tenant = Tenant.find(params[:id])
  end
end
