class OrganizationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_organization, :only => %w{edit update destroy}
  skip_before_filter :authorize, :only => %w{select}

  def index
    begin
      values = Organization.my_organizations.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = Organization.my_organizations.search_for ""
    end

    respond_to do |format|
      format.html do
        @organizations = values.paginate :page => params[:page]
      end
    end
  end

  def new
    @organization = Organization.new
    Taxonomy.no_taxonomy_scope do
      render :new
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
    Taxonomy.no_taxonomy_scope do
      render :edit
    end
  end

  def update
    result = Taxonomy.no_taxonomy_scope do
      @organization.update_attributes(params[:organization])
    end

    if result
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
    @organization = params[:id] ? Organization.find(params[:id]) : nil
    Organization.current = @organization
    session[:org_id] = @organization ? @organization.id : nil
    redirect_back_or_to root_url
  end

  private
  def find_organization
    @organization = Organization.find(params[:id])
  end
end
