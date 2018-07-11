class ComputeAttributesController < ApplicationController
  include Foreman::Controller::Parameters::ComputeAttribute
  before_action :set_redirect_path, only: [:new, :edit]
  after_action :reset_redirect_path, only: [:create, :update]

  def new
    @set = ComputeAttribute.new(:compute_profile_id => params[:compute_profile_id].to_i,
                                :compute_resource_id => params[:compute_resource_id].to_i)
  end

  def create
    @set = ComputeAttribute.new(normalized_compute_attribute_params)
    path = session.fetch(:redirect_path, compute_profiles_path)
    if @set.save
      redirect_to path
    else
      process_error :object => @set
    end
  end

  def edit
    @set = ComputeAttribute.find_by_id(params[:id])
  end

  def update
    @set = ComputeAttribute.find(params[:id])

    path = session.fetch(:redirect_path, compute_profiles_path)
    if @set.update(normalized_compute_attribute_params)
      redirect_to path
    else
      process_error :object => @set
    end
  end

  private

  def reset_redirect_path
    session[:redirect_path] = nil
  end

  def set_redirect_path
    session[:redirect_path] = request.referer
  end
end
