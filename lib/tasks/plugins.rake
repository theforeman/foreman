desc "List Installed plugins"
task :plugins => :environment do
  puts 'Collecting plugin information'
  Foreman::Plugin.all.map{ |p| puts p.to_s }
end
