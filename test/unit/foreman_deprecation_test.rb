require 'test_helper'

class ForemanDeprecationTest < ActiveSupport::TestCase
  test "deadline version is higher than current version and version name in right format" do
    ActiveSupport::Deprecation.expects(:warn).with("You are using a deprecated behavior, it will be removed in version 1.9, More info", instance_of(Array))
    assert_nothing_raised do
      Foreman::Deprecation.deprecation_warning("1.9", "More info")
    end
  end
  test "version name in wrong format, should raise exception" do
    assert_raises Foreman::Exception do
      Foreman::Deprecation.deprecation_warning("1.1.3", "More info")
    end
    assert_raises Foreman::Exception do
      Foreman::Deprecation.deprecation_warning("1.1r", "More info")
    end
  end
  test "calling API deprecation" do
    Foreman::Logging.logger('api_deprecations')
    assert_nothing_raised do
      Foreman::Deprecation.api_deprecation_warning("More info")
    end
  end
end
