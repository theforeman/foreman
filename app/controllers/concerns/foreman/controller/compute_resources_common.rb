module Foreman::Controller::ComputeResourcesCommon
  extend ActiveSupport::Concern

  def compute_resource_error(listing, error)
    Foreman::Logging.exception("Error has occurred while listing #{listing} on #{@compute_resource}", error)
    render :partial => 'compute_resources_vms/error', :locals => { :errors => error.message, :listing => listing }
  end
end
