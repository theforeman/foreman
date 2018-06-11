class ApplicationJob < ActiveJob::Base
  def humanized_name
    self.class.name
  end

  def self.spawn_if_missing(world)
    return if (Foreman.in_rake? && !Foreman.in_rake?('dynflow:executor')) || Rails.env.test?

    pending_jobs = world.persistence.find_execution_plans(filters: { :state => 'scheduled' })
    scheduled_job = pending_jobs.select do |job|
      delayed_plan = world.persistence.load_delayed_plan job.id
      next unless delayed_plan.present?
      arg = delayed_plan.to_hash[:serialized_args].first
      arg.is_a?(Hash) && arg['job_class'] == self.to_s
    end

    # Schedule the job only if it doesn't exit yet
    self.perform_later if scheduled_job.blank?
  end
end
