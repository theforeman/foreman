namespace :plugin do
  desc "List Installed plugins"
  task :list => :environment do
    puts 'Collecting plugin information'
    Foreman::Plugin.all.map{ |p| puts p.to_s }
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
end
