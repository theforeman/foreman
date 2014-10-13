class ForemanMiniTest < MiniTest::Unit

  def _run_suites(suites, type)
    suites.each do |suite|
      next unless type == :test
      next unless suite.respond_to? "test_methods"
      next unless Foreman::Plugin.tests_to_skip.keys.include?(suite.to_s)

      # Extend test_methods to filter out skipped tests
      class << suite
        alias_method :test_methods_without_filtering, :test_methods
        def test_methods
          test_methods_without_filtering.reject do |test|
            unless Foreman::Plugin.tests_to_skip[self.to_s].nil?
              Foreman::Plugin.tests_to_skip[self.to_s].detect do |string|
                # Use a substring match, as test => "test_0010_foo" and string => "foo"
                if test[string]
                  puts "skipping #{self.to_s}##{test}"
                  string
                end
              end
            end
          end
        end
      end
    end

    super(suites, type)
  end

end

MiniTest::Unit.runner = ForemanMiniTest.new
