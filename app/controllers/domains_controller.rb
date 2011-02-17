class DomainsController < ApplicationController
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search  = Domain.search params[:search]
        @domains = @search.paginate :page => params[:page], :include => 'hosts'
      end
      format.json { render :json => Domain.all }
    end
  end

  def new
    @domain = Domain.new
    @domain.domain_parameters.build
  end

  def show
    respond_to do |format|
      format.json { render :json => @domain }
    end
  end

  def create
    @domain = Domain.new(params[:domain])
    if @domain.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes(params[:domain])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @domain.destroy
      process_success
    else
      process_error
    end
  end

end
