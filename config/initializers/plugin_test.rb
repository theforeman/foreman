# This initializer allows to run tests from Foreman plugins
# via rails 5 test runner
# Usage: bundle exec rails test --engine foreman_bootdisk ../foreman_bootdisk/test/unit/example_test.rb
require 'rails/test_unit/runner'

module Foreman
  module RailsRunnerExtensions
    def attach_before_load_options(opts)
      super
      opts.on('--engine ENGINE_NAME', "Load TESTS from ENGINE") {}
    end

    def load_tests(argv)
      engine_name_index = argv.index('--engine')
      engine_name = if engine_name_index
                      argv.delete_at(engine_name_index)
                      argv.delete_at(engine_name_index).strip
                    end

      return super unless engine_name

      puts "Running only tests from engine '#{engine_name}'"

      engine = find_plugin_engine(engine_name)

      unless engine
        puts "Could not find engine '#{engine_name}'"
        return
      end

      $LOAD_PATH.unshift("#{engine.root}/test")

      patterns = extract_filters(argv)

      tests = Rake::FileList[patterns.any? ? patterns : "#{engine.root}/test/**/*_test.rb"]
      tests.exclude("test/system/**/*") if patterns.empty?

      tests.to_a.each { |path| require File.expand_path(path) }
    end

    private

    # this allows referencing reletive directories
    def extract_filters(argv)
      # Extract absolute and relative paths but skip -n /.*/ regexp filters.
      argv.select { |arg| arg =~ %r%^/?[\w.]+/% && !arg.end_with?("/") }.map do |path|
        if path =~ /(:\d+)+$/
          file, *lines = path.split(":")
          filters << [ file, lines ]
          file
        elsif Dir.exist?(path)
          "#{path}/**/*_test.rb"
        else
          filters << [ path, [] ]
          path
        end
      end
    end

    def find_plugin_engine(engine_name)
      ::Rails::Engine.descendants.detect do |engine|
        begin
          engine.engine_name == engine_name
        rescue StandardError
          nil
        end
      end
    end
  end
end

Rails::TestUnit::Runner.singleton_class.prepend(Foreman::RailsRunnerExtensions)
