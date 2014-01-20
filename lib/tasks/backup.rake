namespace :db do
  desc "Make a dump of your database"
  task :dump => :environment do
    config      = Rails.configuration.database_configuration[Rails.env]
    backup_name = "foreman.#{Time.now.to_i}.sql"
    case config['adapter']
    when 'mysql', 'mysql2'
      mysql_dump(backup_name, config)
    when 'postgresql'
      postgres_dump(backup_name, config)
    when 'sqlite'
      backup_name = "foreman.#{Time.now.to_i}.sqlite_copy"
      sqlite_dump(backup_name, config)
    else
      puts 'Your database is not supported by Foreman.' and exit(1)
    end

    puts "Backup in file #{backup_name}"
  end

  def mysql_dump(name, config)
    cmd = "mysqldump #{config['database']} -u #{config['username']} "
    cmd += " -p#{config['password']} " if config['password'].present?
    cmd += " -h #{config['host']} "    if config['host'].present?
    cmd += " -P #{config['port']} "    if config['port'].present?
    cmd += " > #{name}"
    system(cmd)
  end

  def postgres_dump(name, config)
    cmd = "pg_dump #{config['database']} -U #{config['username']} "
    cmd += " -h #{config['host']} "    if config['host'].present?
    cmd += " -p #{config['port']} "    if config['port'].present?
    cmd += " > #{name}"
    system({'PGPASSWORD' => config['password']}, cmd)
  end

  def sqlite_dump(name, config)
    cmd = "cp #{config['database']} #{name}"
    system(cmd)
  end

  desc 'Import your database dump'
  task :import_dump => :environment do
  end
end
