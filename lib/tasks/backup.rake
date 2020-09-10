require "fileutils"

namespace :db do
  desc <<~END_DESC
    Make a dump of your database

    Foreman will make a dump of your database at the provided location, or it will put it in #{File.expand_path('../../db', __dir__)} if no destination file is provided.
    A valid config/database.yml file with the database details is needed to perform this operation.

    Available conditions:
      * destination => path to dump output file (defaults to #{File.expand_path('../../db', __dir__)}/foreman.EPOCH.sql)
      * tables => optional comma separated list of tables (you can use regex to match multiple)
                  Specifies the list of tables to include in the dump.
                  This option works for postgres only.
      Example:
        rake db:dump destination=/mydir/dumps/foreman.sql RAILS_ENV=production # puts production dump in /mydir/dumps/foreman.sql
        rake db:dump tables="hostgro.*"# will match ["hostgroup_classes", "hostgroups"]

  END_DESC

  task :dump => :environment do
    config      = Rails.configuration.database_configuration[Rails.env]
    backup_dir  = File.expand_path('../../db', __dir__)
    backup_name = ENV['destination'] || File.join(backup_dir, "foreman.#{Time.now.to_i}")
    unless ENV["destination"].present?
      backup_name << '.sql'
    end

    if ENV['tables'].present?
      tables = get_matched_tables(ENV['tables'].split(","))
      if tables.blank?
        puts "No tables matching your pattern. '#{ENV['tables']}'."
        exit(0)
      else
        puts "Generating dump for the following tables -> #{tables.inspect}"
      end
    else
      tables = []
    end
    puts "Your backup is going to be created in: #{backup_name}"
    case config['adapter']
    when 'postgresql'
      postgres_dump(backup_name, config, tables)
    else
      puts 'Your database is not supported by Foreman.' and exit(1)
    end

    puts "Completed."
  end

  def postgres_dump(name, config, tables = [])
    cmd = "pg_dump -Fc #{config['database']} -U #{config['username']} "
    cmd += " -h #{config['host']} "    if config['host'].present?
    cmd += " -p #{config['port']} "    if config['port'].present?
    cmd += " " + (tables.map { |t| "-t #{t}" }).join(" ") + " " if tables.present?
    cmd += " > #{name}"
    system({'PGPASSWORD' => config['password']}, cmd)
  end

  def get_matched_tables(input_table_names)
    existing_tables = ActiveRecord::Base.connection.tables.sort
    input_table_names.map do |table_name|
      table_name.strip!
      if existing_tables.include? table_name
        table_name
      else
        existing_tables.grep(/#{table_name}/)
      end
    end.flatten
  end

  desc <<~END_DESC
    Import a database dump

    Foreman will import a database from the provided location.
    A valid config/database.yml file with the database details is needed to perform this operation.

    Available conditions:
      * file => database dump file path

      Example:
        rake db:import_dump file=/mydir/dumps/foreman.db RAILS_ENV=production # imports /mydir/dumps/foreman.db as the production db
  END_DESC

  task :import_dump => :environment do
    unless ENV['file']
      puts "Run this task with a file argument with the location of your db dump,
            'rake db:import_dump file=DBDUMPLOCATION" and return
    end
    config = Rails.configuration.database_configuration[Rails.env]

    puts "Your backup is going to be imported from: #{ENV['file']}"
    puts "You can backup the old database '#{config['database']}' by running:"
    puts " - foreman-rake db:dump destination=/mydir/dumps/foreman.sql RAILS_ENV=#{Rails.env}"
    puts "This task will destroy your old database tables! Are you sure you want to continue? [y/N]"
    input = STDIN.gets.chomp
    abort("Bye!") unless input.downcase == "y"
    case config['adapter']
    when 'postgresql'
      postgres_import(ENV['file'], config)
    else
      puts 'Your database dump cannot be imported by Foreman.' and exit(1)
    end

    puts "Completed."
  end

  def postgres_import(file, config)
    cmd = "pg_restore -d #{config['database']} -U #{config['username']} --clean"
    cmd += " -h #{config['host']} " if config['host'].present?
    cmd += " -p #{config['port']} " if config['port'].present?
    cmd += " #{file}"
    system({'PGPASSWORD' => config['password']}, cmd)
    system(cmd)
  end
end
