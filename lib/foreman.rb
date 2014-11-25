require 'securerandom'
module Foreman
  # generate a UUID
  def self.uuid
    SecureRandom.uuid.to_s
  end

  UUID_REGEXP = Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-" +
                           "([0-9a-f]{2})([0-9a-f]{2})-([0-9a-f]{12})$")
  # does this look like a UUID?
  def self.is_uuid?(str)
    !!(str =~ UUID_REGEXP)
  end

  def self.in_rake?(rake_task = nil)
    defined?(Rake) && Rake.application.top_level_tasks.any? do |running_rake_task|
      rake_task.nil? || running_rake_task == rake_task
    end
  end
end
