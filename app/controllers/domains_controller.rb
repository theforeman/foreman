class DomainsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{edit update destroy}

  def index
    @domains      = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @host_counter = Host.group(:domain_id).where(:domain_id => @domains.select(&:id)).count
  end

  def new
    @domain = Domain.new
    @domain.domain_parameters.build
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
