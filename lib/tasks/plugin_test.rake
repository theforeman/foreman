require File.expand_path('../../config/environment', File.dirname(__FILE__))

desc 'Run a single or multiple plugins tests - called via rake plugin:test[plugin_name,plugin_name]'
task 'plugin:test' => [:environment] do |t, args|
  plugin_names = args.extras
    
  puts "You must specify the name of at least one plugin (e.g. rake plugin:test['my_plugin'])" if plugin_names.empty?

  plugins = plugin_names.collect do |plugin_name|
    plugin = Foreman::Plugin.find(plugin_name)
    unless plugin
      puts "No plugin found for #{plugin_name}. Available plugins are:"
      Rake::Task['plugin:list'].invoke
      exit 1
    end
    plugin
  end

  plugins.each do |plugin|
    test_task = plugin.test_task.nil? ? "plugin:test:#{plugin.name}" : plugin.test_task
    Rake::Task["test"].enhance [test_task]
  end

  Rake::Task['test'].invoke
end

Foreman::Plugin.all.each do |plugin|
  namespace 'plugin:test' do
    desc "Run the #{plugin.name} plugin test suite"
    task plugin.name => ['db:test:prepare'] do
      if plugin.test_task
        test_task = plugin.test_task
      else
        test_task = Rake::TestTask.new("#{plugin.name}_test_task") do |t|
          t.libs.concat(["#{Rails.root}/test", "#{plugin.path}/test"])
          t.test_files = [
            "#{plugin.path}/test/**/*_test.rb"
          ]
          t.verbose = true
        end
        test_task = test_task.name
      end
      
      Rake::Task[test_task].invoke
    end
  end

  namespace 'plugin:rubocop' do
    desc "Run Rubocop on #{plugin.name}"
    task plugin.name do
      begin
        require 'rubocop/rake_task'
        rubocop_task = RuboCop::RakeTask.new("#{plugin.name}_docker") do |task|
          task.patterns = ["#{plugin.path}/app/**/*.rb",
                           "#{plugin.path}/lib/**/*.rb",
                           "#{plugin.path}/test/**/*.rb"]
        end
      rescue
        puts "Rubocop not loaded."
      end

      Rake::Task[rubocop_task.name].invoke
    end
  end
end

begin
  desc 'CI plugin test task for running a single or multiple plugins tests - called via rake plugin:jenkins[plugin_name,plugin_name]'
  task 'plugin:jenkins' => [:environment] do |t, args|
    plugin_names = args.extras
      
    puts "You must specify the name of at least one plugin (e.g. rake plugin:jenkins['my_plugin'])" if plugin_names.empty?

    # Reset to the base Jenkins unit test in case plugins are enhancing it
    Rake::Task['jenkins:unit'].clear
    load 'lib/tasks/jenkins.rake'

    plugins = plugin_names.collect do |plugin_name|
      plugin = Foreman::Plugin.find(plugin_name)
      unless plugin
        puts "No plugin found for #{plugin_name}. Available plugins are:"
        Rake::Task['plugin:list'].invoke
        exit 1
      end
      plugin
    end

    plugins.each do |plugin|
      test_task = plugin.test_task.nil? ? "plugin:test:#{plugin.name}" : plugin.test_task
      rubocop_task = "plugin:rubocop:#{plugin.name}"
      Rake::Task["jenkins:unit"].enhance [rubocop_task]
      Rake::Task["jenkins:unit"].enhance [test_task]
    end

    Rake::Task['jenkins:unit'].invoke
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end
