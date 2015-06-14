require 'test_helper'

class ForemanDeprecationTest < ActiveSupport::TestCase
  test "deadline version is higher than current version and version name in right format" do
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
end

