class ComputeAttributesController < ApplicationController
  include Foreman::Controller::Parameters::ComputeAttribute
  include Foreman::Controller::NormalizeScsiAttributes

  def new
    @set = ComputeAttribute.new(:compute_profile_id => params[:compute_profile_id].to_i,
                                :compute_resource_id => params[:compute_resource_id].to_i)
  end

  def create
    normalize_scsi_attributes(compute_profile_params["vm_attrs"]) if compute_attribute_params["vm_attrs"] && compute_attribute_params["vm_attrs"]["scsi_controllers"]
    @set = ComputeAttribute.new(compute_attribute_params)
    if @set.save
      process_success :success_redirect => request.referer || compute_profile_path(@set.compute_profile)
    else
      process_error :object => @set
    end
  end

  def edit
    @set = ComputeAttribute.find_by_id(params[:id])
  end

  def update
    normalize_scsi_attributes(compute_attribute_params["vm_attrs"]) if compute_attribute_params["vm_attrs"] && compute_attribute_params["vm_attrs"]["scsi_controllers"]
    @set = ComputeAttribute.find(params[:id])
    if @set.update_attributes(compute_attribute_params)
      process_success :success_redirect => request.referer || compute_profile_path(@set.compute_profile)
    else
      process_error :object => @set
    end
  end
end
