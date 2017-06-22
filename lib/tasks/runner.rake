task :runner=> :environment do
  Rails.application.require_environment!
  Rails.application.load_runner
  file=ENV['SCRIPT']
  code=ENV['EVAL']
  if !code && !file
    puts "Either specify EVAL='Hostgroup.find(100)' or specify a script to run with SCRIPT=PATH_TO_FILE"
  end

  User.current = User.anonymous_admin
  puts eval(code, binding, __FILE__, __LINE__) if code
  if file
    if File.exist? file
      Kernel.load file
    else
      puts "#{file} not found" unless File.exist? file
    end
  end
end
