require "fileutils"

namespace :db do
  desc <<-END_DESC
Make a dump of your database

Foreman will make a dump of your database at the provided location, or it will put it in #{File.expand_path('../../../db', __FILE__)} if no destination file is provided.
A valid config/database.yml file with the database details is needed to perform this operation.

Available conditions:
  * destination => path to dump output file (defaults to #{File.expand_path('../../../db', __FILE__)}/foreman.EPOCH.sql)

  Example:
    rake db:dump destination=/mydir/dumps/foreman.sql RAILS_ENV=production # puts production dump in /mydir/dumps/foreman.sql
END_DESC

  task :dump => :environment do
    config      = Rails.configuration.database_configuration[Rails.env]
    backup_dir  = File.expand_path('../../../db', __FILE__)
    backup_name = ENV['destination'] || File.join(backup_dir,"foreman.#{Time.now.to_i}")
    unless ENV["destination"].present?
      if config["adapter"] == "sqlite3"
        backup_name << '.sqlite3'
      else
        backup_name << '.sql'
      end
    end

    puts "Your backup is going to be created in: #{backup_name}"
    case config['adapter']
    when 'mysql', 'mysql2'
      mysql_dump(backup_name, config)
    when 'postgresql'
      postgres_dump(backup_name, config)
    when 'sqlite3'
      sqlite_dump(backup_name, config)
    else
      puts 'Your database is not supported by Foreman.' and exit(1)
    end

    puts "Completed."
  end

  def mysql_dump(name, config)
    cmd = "mysqldump --opt #{config['database']} -u #{config['username']} "
    cmd += " -p#{config['password']} " if config['password'].present?
    cmd += " -h #{config['host']} "    if config['host'].present?
    cmd += " -P #{config['port']} "    if config['port'].present?
    cmd += " > #{name}"
    system(cmd)
  end

  def postgres_dump(name, config)
    cmd = "pg_dump -Fc #{config['database']} -U #{config['username']} "
    cmd += " -h #{config['host']} "    if config['host'].present?
    cmd += " -p #{config['port']} "    if config['port'].present?
    cmd += " > #{name}"
    system({'PGPASSWORD' => config['password']}, cmd)
  end

  def sqlite_dump(name, config)
    FileUtils.cp config['database'], name
  end

  desc <<-END_DESC
Import a database dump

Foreman will import a database from the provided location.
A valid config/database.yml file with the database details is needed to perform this operation.

Available conditions:
  * file => database dump file path

  Example:
    rake db:import_dump file=/mydir/dumps/foreman.db RAILS_ENV=production # imports /mydir/dumps/foreman.db as the production db
END_DESC

  task :import_dump => :environment do
    puts "Run this task with a file argument with the location of your db dump,
          'rake db:import_dump file=DBDUMPLOCATION" and return unless ENV['file']
    config = Rails.configuration.database_configuration[Rails.env]

    puts "Your backup is going to be imported from: #{ENV['file']}"
    case config['adapter']
    when 'mysql', 'mysql2'
      mysql_import(ENV['file'], config)
    when 'postgresql'
      postgres_import(ENV['file'], config)
    when 'sqlite3'
      sqlite_import(ENV['file'], config)
    else
      puts 'Your database dump cannot be imported by Foreman.' and exit(1)
    end

    puts "Completed."
  end

  def mysql_import(file, config)
    cmd = "mysql #{config['database']} -u #{config['username']} "
    cmd += " -p#{config['password']} " if config['password'].present?
    cmd += " -h #{config['host']} "    if config['host'].present?
    cmd += " -P #{config['port']} "    if config['port'].present?
    cmd += " < #{file}"
    system(cmd)
  end

  def postgres_import(file, config)
    cmd = "pg_restore -d #{config['database']} -U #{config['username']} "
    cmd += " -h #{config['host']} " if config['host'].present?
    cmd += " -p #{config['port']} " if config['port'].present?
    cmd += " #{file}"
    system({'PGPASSWORD' => config['password']}, cmd)
    system(cmd)
  end

  def sqlite_import(name, config)
    FileUtils.cp name, config['database']
  end
end
