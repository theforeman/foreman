class ApplicationJob < ActiveJob::Base
  def humanized_name
    self.class.name
  end

  def self.spawn_if_missing(world)
    unless Foreman.in_rake? || Rails.env.test?
      pending_jobs = world.persistence.find_execution_plans(filters: { :state => 'scheduled' })
      scheduled_job = pending_jobs.select do |job|
        delayed_plan = world.persistence.load_delayed_plan job.id
        next unless delayed_plan.present?
        delayed_plan.to_hash[:serialized_args].first.try(:[], 'job_class') == self.to_s
      end

      # Only create notifications if there isn't a scheduled job
      self.perform_later if scheduled_job.blank?
    end
  end
end
