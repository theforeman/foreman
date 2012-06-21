class OrganizationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy select}

  def index
    orgs = Organization.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @organizations = orgs.paginate :page => params[:page] }
      format.json { render :json => orgs }
    end
  end

  def new
    @organization = Organization.new
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @organization }
    end
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
  end

  def update
    if @organization.update_attributes(params[:organization])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @organization.destroy
      process_success
    else
      process_error
    end
  end

  def select
    Organization.current = @organization
    redirect_back_or_to root_url
  end
end
