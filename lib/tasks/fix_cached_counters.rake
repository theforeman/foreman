desc 'Fix cached counters by reseting them to the correct count, in case they got corrupted somehow'
task :fix_cached_counters => :environment do
  puts "Correcting cached counters: (this may take a few minutes)"
  [ Architecture, Environment, Operatingsystem, Domain, Realm].each do |cl|
    cl.all.each{|el| cl.reset_counters(el.id, :hosts, :hostgroups)}
    puts "#{cl} corrected"
  end
  Puppetclass.all.each{|el| Puppetclass.reset_counters(el.id, :hostgroup_classes, :lookup_keys)}
  puts "Puppetclass corrected"
  Model.all.each{|el| Model.reset_counters(el.id, :hosts)}
  puts "Model corrected"
  ConfigGroup.all.each{|el| ConfigGroup.reset_counters(el.id, :config_group_classes)}
  puts "ConfigGroup corrected"
  LookupKey.all.each{|el| LookupKey.reset_counters(el.id, :lookup_values)}
  puts "LookupKey corrected"
end

