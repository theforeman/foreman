require "fileutils"

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
        if not line =~ /^\s*#/ and not line =~ ignored
          output.puts '# TRANSLATORS: "Table name" or "Table name|Column name" for error messages'
          output.puts line
        end
      end
    end
    FileUtils.rm "#{filename}.tmp"
  end

  # just revert to the traditional underscore.
  GettextI18nRailsJs::JsAndCoffeeParser.js_gettext_function = '_' if defined? GettextI18nRailsJs

  desc 'Extract strings from codebase'
  task :find_code => [:find_model, "gettext:find", "gettext:po_to_json"]

  desc 'Extract strings from model and from codebase'
  task :find => [:find_model, :find_code] do
    errors = File.open("locale/foreman.pot") {|f| f.grep /(%s.*%s|#\{)/}
    if errors.count > 0
      errors.each {|e| puts "MALFORMED: #{e}"}
      puts "Malformed strings found: #{errors.count}"
      puts "Please read http://projects.theforeman.org/projects/foreman/wiki/Translating"
    end
  end

  desc 'Alias for gettext:pack'
  task :pack => "gettext:pack"
end
