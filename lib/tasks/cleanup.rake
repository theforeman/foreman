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

    if ActiveRecord::Base.connection.column_exists?(:template_combinations, :environment_id)
      ActiveRecord::Base.connection.remove_reference(:template_combinations, :environment)
    end
    ActiveRecord::Base.connection.drop_table(:host_config_groups, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:config_group_classes, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:config_groups, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:operatingsystems_puppetclasses, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:host_classes, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:hostgroup_classes, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:environment_classes, if_exists: true, force: :cascade)
    ActiveRecord::Base.connection.drop_table(:puppetclasses, if_exists: true, force: :cascade)
    if ActiveRecord::Base.connection.column_exists?(:hosts, :environment_id)
      ActiveRecord::Base.connection.remove_foreign_key :hosts, :environments, name: 'hosts_environment_id_fk'
      ActiveRecord::Base.connection.remove_column :hosts, :environment_id
    end
    if ActiveRecord::Base.connection.column_exists?(:hostgroups, :environment_id)
      ActiveRecord::Base.connection.remove_foreign_key :hostgroups, :environments, name: 'hostgroups_environment_id_fk'
      ActiveRecord::Base.connection.remove_column :hostgroups, :environment_id
    end
    ActiveRecord::Base.connection.drop_table(:environments, if_exists: true, force: :cascade)

    ActiveRecord::SchemaMigration.
      where(version: %w[20090722141107 20090802062223 20110412103238 20110712070522
                        20120824142048 20120905095532 20121018152459 20130725081334
                        20140318153157 20140407161817 20140407162007 20140407162059
                        20140413123650 20140415032811 20141109131448 20150614171717
                        20160307120453 20160626085636 20180831115634 20181023112532
                        20181224174419]).delete_all

    envs = %w[view_environments create_environments edit_environments destroy_environments import_environments]
    cfgs = %w[view_config_groups create_config_groups edit_config_groups destroy_config_groups]
    plks = %w[view_external_parameters create_external_parameters edit_external_parameters
              destroy_external_parameters]
    pcls = %w[view_puppetclasses create_puppetclasses edit_puppetclasses destroy_puppetclasses import_puppetclasses]
    perms = Permission.where(name: envs + cfgs + plks + pcls)
    perms.destroy_all
    Filter.where.not(id: Filtering.distinct.select(:filter_id)).destroy_all

    Feature.where(name: 'Puppet').destroy_all

    organizations = Organization.where("ignore_types LIKE '%Environment%'")
    locations = Location.where("ignore_types LIKE '%Environment%'")

    User.as_anonymous_admin do
      (organizations + locations).each do |tax|
        new_types = tax.ignore_types.reject { |type| type == "Environment" }
        tax.update ignore_types: new_types
      end
    end
  end

  task all: ['purge:trends', 'purge:puppet']
end
task purge_data: 'purge:all'
