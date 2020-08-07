namespace :plugin do
  desc "List Installed plugins"
  task :list => :environment do
    puts 'Collecting plugin information'
    Foreman::Plugin.all.map { |p| puts p.to_s }
  end

  desc 'Validate permissions for built-in roles'
  task :validate_roles => :environment do
    Foreman::Plugin.all.each do |plugin|
      plugin.default_roles.each do |role, expected_perms|
        actual_perms = Role.find_by_name(role).permissions.collect(&:name).collect(&:to_sym)
        missing = actual_perms - expected_perms
        puts "Role '#{role}' is missing permissions #{missing.inspect}" unless missing.empty?
      end
    end
  end

  task :refresh_migrations => :environment do
    # when calling `rake db:create db:migrate` the migrations_paths
    # get loaded before environment, and are not refreshed later. This
    # iterates over the list of migration dires and ensures they are still there.
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths.clear
    Rails.application.config.paths['db/migrate'].each do |path|
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths << path
    end
  end

  task :rubocop, [:engine, :junit] => :environment do |t, args|
    unless args[:engine]
      abort("You must specify the name of the plugin (e.g. rake plugin:rubocop['my_plugin'])")
    end

    engine = "#{args[:engine].tr('-', '_').camelize}::Engine".constantize
    options = []

    options += ['--format', 'progress']
    options += ['--format', 'junit', '--out', args[:junit]] if args[:junit]

    config_path = engine.root.join('.rubocop.yml')
    options += ['--config', config_path.to_s] if config_path.exist?

    options << engine.root.join('{app,lib,test}/**/*.rb').to_s

    require 'rubocop'
    cli = RuboCop::CLI.new
    result = cli.run(options)
    abort('RuboCop failed!') if result.nonzero?
  end
end

Rake::Task["db:migrate"].enhance ['plugin:refresh_migrations']
