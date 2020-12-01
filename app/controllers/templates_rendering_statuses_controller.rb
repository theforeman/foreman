class TemplatesRenderingStatusesController < ApplicationController
  include AuthorizeHelper

  before_action :find_resource, only: [:show]

  def show
    @combinations_count = @templates_rendering_status.combinations
                                                     .group('templates_rendering_status_combinations.status')
                                                     .count
  end

  def model_of_controller
    ::HostStatus::TemplatesRenderingStatus
  end

  def resource_class_for(resource)
    ::HostStatus::TemplatesRenderingStatus
  end
end
