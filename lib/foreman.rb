require 'securerandom'
module Foreman
  # generate a UUID
  def self.uuid
    SecureRandom.uuid
  end

  UUID_REGEXP = Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-" +
                           "([0-9a-f]{4})-([0-9a-f]{12})$")
  # does this look like a UUID?
  def self.is_uuid?(str)
    str.is_a?(String) && str.length == 36 && str.match?(UUID_REGEXP)
  end

  def self.in_rake?(*rake_tasks)
    return false unless defined?(Rake) && Rake.respond_to?(:application)
    Rake.application.top_level_tasks.any? do |running_rake_task|
      rake_tasks.empty? || rake_tasks.any? { |rake_task| running_rake_task.start_with?(rake_task) }
    end
  end

  def self.in_setup_db_rake?
    in_rake?('db:create', 'db:migrate', 'db:drop')
  end

  def self.instance_id
    Setting[:instance_id]
  end

  def self.instance_id=(value)
    Setting[:instance_id] = value
  end
end
