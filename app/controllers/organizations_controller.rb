class OrganizationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    begin
      # TODO: Get the resource groups that belong to the current user
      organizations = Organization
      values = organizations.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = organizations.search_for ""
    end

    respond_to do |format|
      format.html do
        @organization = values.paginate :page => params[:page]
      end
    end
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      process_success
    else
      process_error
    end
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])

    if @organzation.update_attributes(params[:organization])
      process_success
    else
      process_error
    end
  end

  def destroy
    @organization = Organization.find(params[:id])

    if @organization.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_organization
    @organization = Organization.find(params[:id])
  end
end
