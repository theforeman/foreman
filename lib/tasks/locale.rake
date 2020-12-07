require "fileutils"

DOMAIN = ENV['DOMAIN'] || 'foreman'

desc 'Locale specific tasks: locale:find'
namespace :locale do
  desc 'Extract strings from model'
  task :find_model => "gettext:store_model_attributes" do
    # Add some extra comments for translators and remove the following entires:
    #
    # something/something
    # Puppet::something
    #
    ignored = /_\('(\w+\/\w+|Puppet:)/

    filename = "locale/model_attributes"
    File.rename "#{filename}.rb", "#{filename}.tmp"
    File.open("#{filename}.rb", "w") do |output|
      IO.foreach("#{filename}.tmp") do |line|
        if !(line =~ /^\s*#/) && !(line =~ ignored)
          output.puts '# TRANSLATORS: "Table name" or "Table name|Column name" for error messages'
          output.puts line
        end
      end
    end
    FileUtils.rm "#{filename}.tmp"
  end

  desc 'Extract strings from codebase'
  task :find_code => ["gettext:find"]

  desc 'Extract strings from model and from codebase'
  find_dependencies = [:find_model, :find_code]
  find_dependencies.shift if ENV['SKIP_MODEL']
  task :find => find_dependencies do
    # find malformed strings
    errors = File.open("locale/#{DOMAIN}.pot") { |f| f.grep /(%s.*%s|#\{)/ }
    if errors.count > 0
      errors.each { |e| puts "MALFORMED: #{e}" }
      puts "Malformed strings found: #{errors.count}"
      puts "Please read https://projects.theforeman.org/projects/foreman/wiki/Translating"
    end
  end

  desc 'Alias for gettext:po_to_json'
  task :po_to_json => Dir['locale/*/foreman.po'].push("gettext:po_to_json")

  desc 'Alias for gettext:pack'
  task :pack => "gettext:pack"
end
