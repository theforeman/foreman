class LocationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_location, :only => %w{edit update destroy clone select_hosts assign_hosts
                                            assign_selected_hosts assign_all_hosts step2}
  before_filter :count_nil_hosts, :only => %w{index create step2}
  skip_before_filter :authorize, :set_taxonomy, :only => %w{select}

  def index
    begin
      values = Location.my_locations.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = Location.my_locations.search_for('')
    end

    respond_to do |format|
      format.html do
        @locations = values.paginate :page => params[:page]
        @counter = Host.group(:location_id).where(:location_id => @locations).count
      end
    end
  end

  def new
    @location = Location.new
    Taxonomy.no_taxonomy_scope do
      # we explicitly render here in order to evaluate the view without taxonomy scope
      render :new
    end
  end

  def clone
   new = @location.clone
   # copy all the relations
   new.name = ""
   new.users             = @location.users
   new.smart_proxies     = @location.smart_proxies
   new.subnets           = @location.subnets
   new.compute_resources = @location.compute_resources
   new.media             = @location.media
   new.domains           = @location.domains
   new.media             = @location.media
   new.hostgroups        = @location.hostgroups
   new.organizations     = @location.organizations

   @location = new
   render :action => :new
  end

  def create
    @location = Location.new(params[:location])
    if @location.save
      if @count_nil_hosts > 0
        redirect_to step2_location_path(@location)
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
      params[:location][:ignore_types] -= ["0"]
      @location.update_attributes(params[:location])
    end
    if result
      process_success
    else
      process_error
    end
  end

  def destroy
    if @location.destroy
      process_success
    else
      process_error
    end
  end

  def select
    @location = params[:id] ? Location.find(params[:id]) : nil
    Location.current = @location
    session[:location_id] = @location ? @location.id : nil
    expire_fragment("tabs_and_title_records-#{User.current.id}")
    redirect_back_or_to root_url
  end

  def mismatches
    @mismatches = Taxonomy.all_mismatcheds
    render 'taxonomies/mismatches'
  end

  def import_mismatches
    @location = Location.find_by_id(params[:id])
    if @location
      @mismatches = @location.import_missing_ids
      redirect_to edit_location_path(@location), :notice => "All mismatches between hosts and #{@location.name} have been fixed"
    else
      Taxonomy.all_import_missing_ids
      redirect_to locations_path, :notice => "All mismatches between hosts and locations/organizations have been fixed"
    end
  end

  def assign_hosts
    @taxonomy = @location
    @taxonomy_type = "Location"
    @hosts = Host.my_hosts.no_location.search_for(params[:search],:order => params[:order]).paginate :page => params[:page], :include => included_associations
    render "hosts/assign_hosts"
  end

  def assign_all_hosts
    Host.no_location.update_all(:location_id => @location.id)
    @location.import_missing_ids
    redirect_to locations_path, :notice => "All hosts previously with no location are now assigned to #{@location.name}"
  end

  def assign_selected_hosts
    host_ids = params[:location][:host_ids] - ["0"]
    @hosts = Host.where(:id => host_ids).update_all(:location_id => @location.id)
    @location.import_missing_ids
    redirect_to locations_path, :notice => "Selected hosts are now assigned to #{@location.name}"
  end

  def count_nil_hosts
    return @count_nil_hosts if @count_nil_hosts
    @count_nil_hosts = Host.where(:location_id => nil).count
  end

  private
  def find_location
    @location = Location.find(params[:id])
  end
end
