class OrganizationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_organization, :only => %w{edit update destroy clone select_hosts assign_hosts
                                            assign_selected_hosts assign_all_hosts step2}
  before_filter :count_nil_hosts, :only => %w{index create step2}
  skip_before_filter :authorize, :set_taxonomy, :only => %w{select}

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
        @counter = Host.group(:organization_id).where(:organization_id => @organizations).count
      end
    end
  end

  def new
    @organization = Organization.new
    Taxonomy.no_taxonomy_scope do
      # we explicitly render here in order to evaluate the view without taxonomy scope
      render :new
    end
  end

  def clone
   new = @organization.clone
   # copy all the relations
   new.name = ""
   new.users             = @organization.users
   new.smart_proxies     = @organization.smart_proxies
   new.subnets           = @organization.subnets
   new.compute_resources = @organization.compute_resources
   new.media             = @organization.media
   new.domains           = @organization.domains
   new.media             = @organization.media
   new.hostgroups        = @organization.hostgroups
   new.locations         = @organization.locations

   @organization = new
   render :action => :new
  end

  def create
    @organization = Organization.new(params[:organization])
    if @organization.save
      if @count_nil_hosts > 0
        redirect_to step2_organization_path(@organization)
      else
        process_success
      end
    else
      process_error
    end
  end

  def edit
    Taxonomy.no_taxonomy_scope do
      # we explicitly render here in order to evaluate the view without taxonomy scope
      render :edit
    end
  end

  def step2
    Taxonomy.no_taxonomy_scope do
      render :step2
    end
  end

  def update
    result = Taxonomy.no_taxonomy_scope do
      params[:organization][:ignore_types] -= ["0"]
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
    expire_fragment("tabs_and_title_records-#{User.current.id}")
    redirect_back_or_to root_url
  end

  def mismatches
    @mismatches = Taxonomy.all_mismatcheds
    render 'taxonomies/mismatches'
  end

  def import_mismatches
    @organization = Organization.find_by_id(params[:id])
    if @organization
      @mismatches = @organization.import_missing_ids
      redirect_to edit_organization_path(@organization), :notice => "All mismatches between hosts and #{@organization.name} have been fixed"
    else
      Taxonomy.all_import_missing_ids
      redirect_to organizations_path, :notice => "All mismatches between hosts and locations/organizations have been fixed"
    end
  end

  def assign_hosts
    @taxonomy = @organization
    @taxonomy_type = "Organization"
    @hosts = Host.my_hosts.no_organization.search_for(params[:search],:order => params[:order]).paginate :page => params[:page], :include => included_associations
    render "hosts/assign_hosts"
  end

  def assign_all_hosts
    Host.no_organization.update_all(:organization_id => @organization.id)
    @organization.import_missing_ids
    redirect_to organizations_path, :notice => "All hosts previously with no organization are now assigned to #{@organization.name}"
  end

  def assign_selected_hosts
    host_ids = params[:organization][:host_ids] - ["0"]
    @hosts = Host.where(:id => host_ids).update_all(:organization_id => @organization.id)
    @organization.import_missing_ids
    redirect_to organizations_path, :notice => "Selected hosts are now assigned to #{@organization.name}"
  end

  def count_nil_hosts
    return @count_nil_hosts if @count_nil_hosts
    @count_nil_hosts = Host.where(:organization_id => nil).count
  end

  private
  def find_organization
    @organization = Organization.find(params[:id])
  end
end
