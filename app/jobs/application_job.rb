class ApplicationJob < ActiveJob::Base
  def humanized_name
    self.class.name
  end

  def self.spawn_if_missing(world)
    return if (Foreman.in_rake? && !Foreman.in_rake?('dynflow:executor')) || Rails.env.test?

    # While in scheduled and planning, the execution plan still doesn't have its label set, but it could have
    # a delayed plan record, which should contain the data we need to match
    scheduled_plans = world.persistence.find_execution_plans(filters: { :state => %w(planning scheduled) })
                           .select do |job|
                             delayed_plan = world.persistence.load_delayed_plan job.id
                             next unless delayed_plan.present?
                             arg = delayed_plan.to_hash[:serialized_args].first
                             arg.is_a?(Hash) && arg['job_class'] == to_s
                           end

    # The delayed plan record gets deleted somewhere during the planned -> running transition so we cannot use it anymore
    # However when a plan gets planned, its label gets set and we can use that instead
    in_progress_plans = world.persistence.find_execution_plans(filters: { :state => %w(planned running), :label => name })

    # Schedule the job only if it doesn't exit yet
    perform_later if (scheduled_plans + in_progress_plans).blank?
  end
end
