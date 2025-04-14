class ComputeResourceCleaner
  delegate :logger, :to => ::Rails

  attr_reader :resource_ids

  def initialize(klass:)
    @klass = klass
    @resource_ids = find_compute_resources
  end

  def simulate
    logger.info "Running in simulation mode. Following actions would be performed:"
    return nothing_to_do if @resource_ids.empty?

    logger.info "Compute resources ids to remove: #{@resource_ids}"

    simulate_action(Host, :update)
    simulate_action(Hostgroup, :update)
    simulate_action(ComputeAttribute, :destroy)
    simulate_action(Image, :destroy)
  end

  def run!
    logger.info "Running cleanup for compute resources of type #{@klass}."
    nothing_to_do if @resource_ids.empty?
    logger.info "Compute resources ids to update: #{@resource_ids}"

    ActiveRecord::Base.transaction do
      host_attrs = { compute_resource_id: nil, compute_profile_id: nil, uuid: nil, image_id: nil }
      cleanup_action(Host, :update_all, host_attrs)

      hostgroup_attrs = { compute_resource_id: nil, compute_profile_id: nil }
      cleanup_action(Hostgroup, :update_all, hostgroup_attrs)

      cleanup_action(ComputeAttribute, :delete_all)
      cleanup_action(Image, :delete_all)

      cleanup_compute_resources
    end

    logger.info "Cleanup completed for compute resources of type #{@klass}."
  end

  private

  def find_compute_resources
    ComputeResource.unscoped.where(type: @klass).pluck(:id)
  end

  def nothing_to_do
    logger.info N_("Nothing to do.")
    nil
  end

  def simulate_action(klass, action = :update)
    ids = klass.unscoped.where(compute_resource_id: @resource_ids).pluck(:id)
    action_verb = case action
                  when :destroy
                    "Removing"
                  else
                    "Updating"
                  end

    logger.info "#{action_verb} #{klass} ids: #{ids}"
  end

  def cleanup_action(klass, action, attrs = {})
    logger.info "Performing action '#{action}' on #{klass}(s)"
    klass.unscoped.where(compute_resource_id: @resource_ids).send(action, **attrs)
  end

  def cleanup_compute_resources
    logger.info "Cleaning up compute resources of type #{@klass}."
    ComputeResource.unscoped.where(id: @resource_ids).delete_all
  end
end
