class ComputeAttributesController < ApplicationController

  def new
    @set = ComputeAttribute.new(:compute_profile_id => params[:compute_profile_id].to_i,
                                              :compute_resource_id => params[:compute_resource_id].to_i)
  end

  def create
    @set = ComputeAttribute.new(foreman_params)
    if @set.save
      process_success :success_redirect => request.referer || compute_profile_path(@set.compute_profile)
    else
      process_error
    end
  end

  def edit
    @set = ComputeAttribute.find_by_id(params[:id])
  end

  def update
    @set = ComputeAttribute.find(params[:id])
    if @set.update_attributes!(foreman_params)
      process_success :success_redirect => request.referer || compute_profile_path(@set.compute_profile)
    else
      process_error
    end
  end
end
