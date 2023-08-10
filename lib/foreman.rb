require 'securerandom'

module Foreman
  # generate a UUID
  def self.uuid
    SecureRandom.uuid
  end

  def self.uuid_regexp
    @uuid_regexp ||= Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})$")
  end

  # does this look like a UUID?
  def self.is_uuid?(str)
    str.is_a?(String) && str.length == 36 && str.match?(uuid_regexp)
  end

  def self.in_rake?(*rake_tasks)
    return false unless defined?(Rake) && Rake.respond_to?(:application)
    Rake.application.top_level_tasks.any? do |running_rake_task|
      rake_tasks.empty? || rake_tasks.any? { |rake_task| running_rake_task.start_with?(rake_task) }
    end
  end

  def self.in_setup_db_rake?
    in_rake?('db:create', 'db:migrate', 'db:drop', 'db:abort_if_pending_migrations')
  end

  def self.pending_migrations?
    ActiveRecord::Base.connection.migration_context.needs_migration? || Foreman::Plugin.all.any?(&:pending_migrations)
  end

  def self.instance_id
    Setting[:instance_id]
  end

  def self.instance_id=(value)
    Setting[:instance_id] = value
  end

  def self.input_types_registry
    @input_types_registry ||= Foreman::InputTypesRegistry.new
  end

  def self.settings
    SettingRegistry.instance
  end

  def self.download_utilities
    {
      'curl' => {
        :ca_cert => '--cacert',
        :download_command => 'curl --silent --show-error',
        :insecure => '--insecure',
        :output_file => '--output',
        :request_type_post => '--request POST',
        :format_params => proc { |params| params.map { |param| "--data #{param}" } },
      },
      'wget' => {
        :ca_cert => '--ca-certificate',
        :download_command => 'wget --no-verbose --no-hsts',
        :insecure => '--no-check-certificate',
        :output_file => '--output-document',
        :output_pipe => '--output-document -',
        :format_params => proc { |params| ["--post-data #{params.join('\&')}"] },
      },
    }.freeze
  end
end

# Consider moving these to config.autoload_lib_once in Rails 7.1
require_relative 'foreman/exception' # This could be extracted into separate files and get autoloaded
require_relative 'foreman/force_ssl'
require_relative 'foreman/logging'
require_relative 'foreman/middleware'
require_relative 'foreman/telemetry_helper'
require_relative 'foreman/provision'
