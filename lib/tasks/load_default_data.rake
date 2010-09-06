desc 'Load Foreman default configuration data.'

namespace :foreman do
  task :load_default_data => :environment do

    begin
      Foreman::DefaultData::Loader.load(true)
      puts "Default configuration data reloaded."
    rescue Foreman::DefaultData::DataAlreadyLoaded => error
      puts error
    rescue => error
      puts "Error: " + error
      puts "Default configuration data was not loaded."
    end
  end
end
