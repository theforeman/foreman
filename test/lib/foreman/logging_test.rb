require 'test_helper'

class ForemanLoggingTest < ActiveSupport::TestCase
  def test_configure_once
    assert_raises RuntimeError do
      Foreman::Logging.configure({})
    end
  end

  def test_environment_not_found_yields_defaults
    assert_nothing_raised do
      Foreman::Logging.instance_variable_set("@configured", false)
      # Stub the log file creation (foo.log)
      Foreman::Logging.stubs(:build_file_appender).
        with('foreman', { :environment => 'foo'} ).returns(nil).once
      quietly { Foreman::Logging.configure(:environment => 'foo') }
    end
    log_filename = Foreman::Logging.instance_variable_get("@config")[:filename]
    assert_equal 'foo.log', log_filename
  ensure
    # Return the foreman logger to the original one for the current environment
    Foreman::Logging.unstub(:build_file_appender)
    Foreman::Logging.instance_variable_set("@configured", false)
    Foreman::Logging.configure(:environment => Rails.env)
  end

  def test_default_loggers_exist
    assert Foreman::Logging.logger('app')
    assert Foreman::Logging.logger('sql')
  end

  def test_prevents_nonexistent_logger
    assert_raises RuntimeError do
      Foreman::Logging.logger('nonexistent_logger')
    end
  end

  def test_add_loggers
    Foreman::Logging.add_loggers({:fake_logger => {:enabled => true}})
    assert Foreman::Logging.logger('fake_logger')
  end

  def test_add_logger
    Foreman::Logging.add_logger('test_logger', {:enabled => true, :level => :debug})
    assert Foreman::Logging.logger('test_logger')
  end

  def test_error_config_missing
    File.expects(:exist?).returns(false)

    assert_raises RuntimeError do
      Foreman::Logging.send(:load_config, 'development')
    end
  end

  def test_logger_level
    Foreman::Logging.add_logger('test_logger', {:enabled => true, :level => :debug})
    assert_equal 'debug', Foreman::Logging.logger_level('test_logger')
  end
end
