desc 'Fix cached counters by reseting them to the correct count, in case they got corrupted somehow'
task :fix_cached_counters => :environment do
  puts "Correcting cached counters: (this may take a few minutes)"
  Puppetclass.all.each{|el| Puppetclass.reset_counters(el.id, :lookup_keys)}
  puts "Puppetclass corrected"
  ConfigGroup.all.each{|el| ConfigGroup.reset_counters(el.id, :config_group_classes)}
  puts "ConfigGroup corrected"
  LookupKey.all.each{|el| LookupKey.reset_counters(el.id, :lookup_values)}
  puts "LookupKey corrected"
end

