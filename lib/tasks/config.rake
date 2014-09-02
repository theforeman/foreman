require 'optparse'
require 'json'
require 'yaml'

desc "Configure Foreman in-database settings, see rake config -- --help for more details"
task :config => :environment do
  class ForemanConfig

    attr_reader :options, :changed_settings

    def initialize
      @key              = nil
      @keys             = []
      @key_values       = {}
      @changed_settings = []
    end

    def set_options_key_value(value)
      unless @key
        STDERR.puts("Key has to be specified first")
        exit 2
      end
      @keys << @key
      @key_values[@key] = value
      @key = nil
    end

    def parser
      OptionParser.new do |opt|
        opt.banner = <<BANNER
Get or set the Foremen settings.

Options:
BANNER
        opt.on("-k",
               "--key KEY",
               "If not specified, all keys are displayed") do |val|
          @key = val
        end

        opt.on("-v",
               "--value VALUE",
               "Set the value. The key must be specified. Complex values (hashes, arrays) are expected to be JSON encoded.") do |val|
          set_options_key_value(val)
        end

        opt.on("-u",
               "--unset",
               "Unset the key. The key must be specified") do
          set_options_key_value(:unset)
        end

        opt.on("-h", "--help", "Show help and exit") do
          puts opt
          exit
        end

        opt.on("-n",
               "--dry-run",
               "Don't change thd configuration. Success if no change is needed.") do
          @dry = true
        end
      end
    end

    def run(args)
      parser.parse!(args)

      if @key && @key_values.any?
        puts "Missing value for key '#{ @key }'"
        exit 2
      end

      if @key
        run_single_key
      elsif @key_values.any?
        run_key_values
      else
        run_all
      end

      if @dry
        if changed_settings.empty?
          exit 0
        else
          # dry mode and something would change
          exit 1
        end
      end
    end

    # just a single key was passed: print the value
    def run_single_key
      setting = Setting.find_by_name(@key)
      puts format_value(setting.settings_type, setting.value)
    end

    # key-value pairs were provided: try to change that
    def run_key_values
      @keys.each do |key|
        value = @key_values[key]
        setting = Setting.find_by_name(key)
        old_value = setting.value
        if value == :unset
          value = nil
        elsif complex_type?(setting.settings_type)
          setting.value = typecast_value(setting.settings_type, value)
        else
          setting.parse_string_value(value)
        end
        if setting.valid? && old_value != setting.value
          setting.save! unless @dry
          changed_settings << setting
        end
        puts format_value(setting.settings_type, setting.value)
      end
    end

    # no options: just print all the values
    def run_all
      Setting.all.each do |setting|
        puts "#{setting.name}: #{format_value(setting.settings_type, setting.value)}"
      end
    end

    def complex_type?(type)
      ["hash", "array"].include? type
    end

    # we expect simple values or JSON encoded hashes or arrays (if applicible)
    def typecast_value(type, value)
      if complex_type?(type)
        # we used JSON over custom format for input because it's easier to parse
        JSON.parse(value).inspect
      else
        value
      end
    end

    def format_value(type, value)
      if complex_type?(type)
        value.to_json
      else
        value
      end
    end
  end

  ARGV.shift
  ForemanConfig.new.run(ARGV)
  exit
end

# The db_pending_* settings are handled by the installer. For case
# of not installing with installer, we want to ensure the settings to false
# at the end of the seeding
Rake::Task['db:seed'].enhance do
  Setting['db_pending_migration'] = false
  Setting['db_pending_seed'] = false
end
