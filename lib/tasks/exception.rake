desc 'Exception utilities'
namespace :exception do
  desc 'List all error codes'
  task :codes => :environment do
    exceptions = [
      'Foreman::Exception',
      'WrappedException',
      'ProxyException',
    ]
    result = {}
    regexp = /raise.*(#{exceptions.join('|')})(\.new)?.*N_\(?(["'])([^\3]+?)\3\)?\)?/
    Dir['app/**/*rb', 'lib/**/*rb'].each do |path|
      File.open(path) do |f|
        f.grep(/#{regexp}/) do |line|
          code = ::Foreman::Exception.calculate_error_code Regexp.last_match(1), Regexp.last_match(4)
          result[code] = Regexp.last_match(4)
        end
      end
    end

    result.keys.sort.each do |k|
      v = result[k]
      puts " * [[#{k}]] - #{v}"
    end
  end
end
