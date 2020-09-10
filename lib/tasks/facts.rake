namespace :facts do
  desc <<~END_DESC
    Removes facts without any values

    This is useful when you used custom facts of different facts sourcers that you don't use anymore.
    After cleaning of such facts they should no longer appear in auto-completion suggestions.

    Examples:
      # foreman-rake facts:clean [batch_size=500]
  END_DESC

  task :clean => :environment do
    batch_size = ENV['batch_size'] ? ENV['batch_size'].to_i : 500
    puts 'Starting orphaned facts clean up'
    count = FactCleaner.new(batch_size: batch_size).clean!.deleted_count
    puts "Finished, cleaned #{count} facts"
  end
end
