class ComputeProfilesController < ApplicationController

  include Foreman::Controller::AutoCompleteSearch

  def index
    base = ComputeProfile.authorized(:view_compute_profiles)
    @compute_profiles = base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def show
    @compute_profile = find_compute_profile(:view_compute_profiles)
  end

  def new
    @compute_profile = ComputeProfile.new
  end

  def edit
    @compute_profile = find_compute_profile(:edit_compute_profiles)
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
    @compute_profile = find_compute_profile(:edit_compute_profiles)
    if @compute_profile.update_attributes(params[:compute_profile])
      process_success :success_redirect => compute_profiles_path
    else
      process_error
    end
  end

  def destroy
    @compute_profile = find_compute_profile(:destroy_compute_profiles)
    if @compute_profile.destroy
      process_success
    else
      process_error
    end
  end

  private

  def find_compute_profile(permission = 'view_compute_profiles')
    ComputeProfile.authorized(permission).find(params[:id])
  end

end
