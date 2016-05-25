namespace :db do
  namespace :sequences do
    desc "Reset values of primary key sequences"
    task :reset => :environment do
      if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        skip_tables = %w(schema_info schema_migrations architectures_operatingsystems config_templates_operatingsystems
                         features_smart_proxies locations_organizations operatingsystems_ptables operatingsystems_puppetclasses
                         media_operatingsystems user_compute_resources user_domains user_facts user_hostgroups user_notices)
        (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
          ActiveRecord::Base.connection.execute "SELECT setval('#{table_name}_id_seq', (SELECT MAX(id) FROM #{table_name}));" rescue "Error on #{table_name}"
        end
        puts "Successfully completed resetting values of primary key sequences for PostgreSQL database #{ActiveRecord::Base.connection.current_database}"
      else
        puts "This rake task only works for PostgreSQL databases and your database has adapter #{ActiveRecord::Base.connection.adapter_name}"
      end
    end
  end
end
