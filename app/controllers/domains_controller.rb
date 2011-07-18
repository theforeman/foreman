class DomainsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    values = Domain.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @domains = values.paginate :page => params[:page], :include => 'hosts' }
      format.json { render :json => values }
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
