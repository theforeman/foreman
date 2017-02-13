namespace :facts do
  desc <<-END_DESC
Removes facts without any values

This is useful when you used custom facts of different facts sourcers that you don't use anymore.
After cleaning of such facts they should no longer appear in auto-completion suggestions.

Examples:
  # foreman-rake facts:clean
END_DESC

  task :clean => :environment do
    puts 'Starting orphaned facts clean up...'
    count = FactCleaner.new.clean!.deleted_count
    puts "Finished, cleaned #{count} facts"
  end
end
