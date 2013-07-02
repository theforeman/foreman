
desc 'Exception utilities'
namespace :exception do

  desc 'List all error codes'
  task :codes => :environment do
    wiki = defined? ENV['WIKI']
    exceptions = [
      ::Foreman::Exception,
      ::Foreman::WrappedException,
    ]
    result = {}
    regexp = /raise.*:?:?(#{exceptions.join('|')})(\.new)?\(?N_\(?(["'])([^\3]+?)\3\)?\)?/
    Dir['app/**/*rb', 'lib/**/*rb'].each do |path|
      File.open(path) do |f|
        f.grep( /#{regexp}/ ) do |line|
          code = ::Foreman::Exception.calculate_error_code $1, $4
          result[$4] = code
        end
      end
    end

    puts "\n\nh1. Foreman error codes:\n\n<pre>\n"
    result.keys.sort.each do |msg|
      code = result[msg]
      puts "#{code} #{msg}"
    end
    puts "</pre>\n\nGenerated with `rake exception:codes`, for more info and options see"
    puts "https://github.com/theforeman/foreman/blob/develop/lib/tasks/exception.rake\n\n"
  end

end
