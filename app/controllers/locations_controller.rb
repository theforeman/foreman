class LocationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_location, :only => %w{edit update destroy}
  skip_before_filter :authorize, :only => %w{select}

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

  def create
    @location = Location.new(params[:location])

    if @location.save
      process_success
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

  def update
    result = Taxonomy.no_taxonomy_scope do
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
    redirect_back_or_to root_url
  end

  private
  def find_location
    @location = Location.find(params[:id])
  end
end
