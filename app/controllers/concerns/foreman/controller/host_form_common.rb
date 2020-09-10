module Foreman::Controller::HostFormCommon
  extend ActiveSupport::Concern

  included do
    define_callbacks :set_class_variables
  end

  private

  def load_vars_for_ajax
    return unless @host

    taxonomy_scope
    if @host.compute_resource_id &&
        respond_to?(:host_params) && host_params && host_params[:compute_attributes]
      @host.compute_attributes = host_params[:compute_attributes]
    end

    set_class_variables(@host)
  end

  def set_class_variables(host)
    run_callbacks :set_class_variables do
      @architecture    = host.architecture
      @operatingsystem = host.operatingsystem
      @domain          = host.domain
      @subnet          = host.subnet
      @compute_profile = host.compute_profile
      @realm           = host.realm
      @hostgroup       = host.hostgroup
    end
  end

  def taxonomy_scope
    if params[:host]
      @organization = Organization.find_by_id(params[:host][:organization_id])
      @location = Location.find_by_id(params[:host][:location_id])
    end

    if @host
      @organization ||= @host.organization
      @location     ||= @host.location
    end

    @organization ||= Organization.find_by_id(params[:organization_id]) if params[:organization_id]
    @location     ||= Location.find_by_id(params[:location_id])         if params[:location_id]

    @organization ||= Organization.current
    @location     ||= Location.current
  end
end
