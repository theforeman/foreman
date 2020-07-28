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
    perms = Permission.where(resource_type: 'Trend')
    perms.each { |perm| perm.filters.destroy_all }
    perms.destroy_all
    Setting.where(name: 'max_trend').delete_all
  end

  task all: ['purge:trends']
end
task purge_data: 'purge:all'
