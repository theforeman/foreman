# First, we check if there's a job already enqueued for RSS notifications
::Foreman::Application.dynflow.config.on_init do |world|
  pending_jobs = world.persistence.find_execution_plans(filters: { :state => 'scheduled' })
  scheduled_job = pending_jobs.select do |job|
    delayed_plan = world.persistence.load_delayed_plan job.id
    next unless delayed_plan.present?
    delayed_plan.to_hash[:serialized_args].first["job_class"] == 'CreateRssNotifications'
  end

  # Only create notifications if there isn't a scheduled job
  CreateRssNotifications.perform_later unless scheduled_job.present?
end
