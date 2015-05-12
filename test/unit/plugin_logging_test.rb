require 'test_helper'

class PluginLoggingTest < ActiveSupport::TestCase
  def setup
    @plugin_config = {:loggers => {:foreman_test_plugin => {:enabled => true}}}
    @logging = Foreman::Plugin::Logging.new("foreman_test_plugin")
    @logging.configure(@plugin_config)
  end

  def assert_logger_exists(name)
    assert ::Logging::Repository.instance.has_logger?(name), "Failed assertion, logger #{name} does not exist"
  end

  def refute_logger_exists(name)
    refute ::Logging::Repository.instance.has_logger?(name), "Failed assertion, logger #{name} exists"
  end

  def test_configure
    @logging.configure(@plugin_config)

    assert_logger_exists 'foreman_test_plugin'
  end

  def test_missing_config
    @logging.configure({})

    assert_logger_exists 'foreman_test_plugin'
  end

  def test_multiple_loggers
    @plugin_config[:loggers][:backend_logger] = {:enabled => true}
    @logging.configure(@plugin_config)

    assert_logger_exists 'foreman_test_plugin/backend_logger'
    refute_logger_exists 'backend_logger'
  end

  def test_namespace
    assert_equal "foreman_test_plugin", @logging.namespace(:foreman_test_plugin)
    assert_equal "foreman_test_plugin/backend_logger", @logging.namespace(:backend_logger)
  end
end
