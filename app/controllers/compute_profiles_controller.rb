class ComputeProfilesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:show, :edit, :update, :destroy]

  def index
    @compute_profiles = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def show
  end

  def new
    @compute_profile = ComputeProfile.new
  end

  def edit
  end

  def create
    @compute_profile = ComputeProfile.new(params[:compute_profile])
    if @compute_profile.save
      process_success :success_redirect => compute_profile_path(@compute_profile)
    else
      process_error
    end
  end

  def update
    if @compute_profile.update_attributes(params[:compute_profile])
      process_success :success_redirect => compute_profiles_path
    else
      process_error
    end
  end

  def destroy
    if @compute_profile.destroy
      process_success
    else
      process_error
    end
  end

end
