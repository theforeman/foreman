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

  desc 'Extract strings from model and from codebase'
  task :find => [:find_model, "gettext:find"]

end
