namespace :trends do
  def ensure_statistics_plugin(operation)
    Foreman::Deprecation.deprecation_warning('2.4', 'Trends have been extracted to plugin and will be removed from core')
    plugin = Foreman::Plugin.find(:foreman_statistics)
    fail "For running #{operation} you need to install Foreman Statistics plugin" unless plugin
  end

  desc 'Create Trend counts'
  task :counter => :environment do
    ensure_statistics_plugin('trends:counter')
    Rake::Task['foreman_statistics:trends:counter'].invoke
  end

  desc 'Reduces amount of points for each trend group'
  task :reduce => :environment do
    ensure_statistics_plugin('trends:reduce')
    Rake::Task['foreman_statistics:trends:reduce'].invoke
  end
end
