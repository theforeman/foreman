class TaxonomiesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy select}

  def index
    taxonomies = Taxonomy.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @taxonomies = taxonomies.paginate :page => params[:page] }
      format.json { render :json => taxonomies }
    end
  end

  def new
    @taxonomy = Taxonomy.new
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @taxonomy }
    end
  end

  def create
    @taxonomy = Taxonomy.new(params[:organization])
    if @taxonomy.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @taxonomy.update_attributes(params[:organization])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @taxonomy.destroy
      process_success
    else
      process_error
    end
  end

  def select
    Taxonomy.current = @taxonomy
    redirect_back_or_to root_url
  end
end
