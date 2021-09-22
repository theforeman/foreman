# TRANSLATORS: do not translate
desc <<~END_DESC
  Purge data left over after extraction of some funcionalities.
END_DESC

namespace :purge do
  desc 'Clean up all Trends data'
  task trends: :environment do
    ActiveRecord::Base.connection.drop_table(:trend_counters, if_exists: true)
    ActiveRecord::Base.connection.drop_table(:trends, if_exists: true)
    # Migration names: create_trends create_trend_counters add_range_to_trend_counters add_trend_counter_created_at_unique_constraint
    ActiveRecord::SchemaMigration.where(version: %w[20121012170851 20121012170936 20150202094307 20181031155025]).delete_all
    perms = Permission.where(name: %w[view_statistics view_trends create_trends edit_trends destroy_trends update_trends])
    perms.each { |perm| perm.filters.destroy_all }
    perms.destroy_all
    Setting.where(name: 'max_trend').delete_all
  end

  task puppet: :environment do
    raise('You have the Puppet plugin installed, uninstall it first to purge puppet data') if Foreman::Plugin.find(:foreman_puppet)

    envs = %w[view_environments create_environments edit_environments destroy_environments import_environments]
    cfgs = %w[view_config_groups create_config_groups edit_config_groups destroy_config_groups]
    plks = %w[view_external_parameters create_external_parameters edit_external_parameters
              destroy_external_parameters]
    pcls = %w[view_puppetclasses create_puppetclasses edit_puppetclasses destroy_puppetclasses import_puppetclasses]
    perms = Permission.where(name: envs + cfgs + plks + pcls)
    perms.destroy_all
    Filter.where.not(id: Filtering.distinct.select(:filter_id)).destroy_all

    Feature.where(name: 'Puppet').destroy_all
  end

  task all: ['purge:trends']
end
task purge_data: 'purge:all'
