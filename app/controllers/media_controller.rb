class MediaController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Medium

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @media = resource_base.includes(:operatingsystems).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @medium = Medium.new
  end

  def create
    @medium = Medium.new(medium_params)
    if @medium.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @medium.update_attributes(medium_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @medium.destroy
      process_success
    else
      process_error
    end
  end
end
