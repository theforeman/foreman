require 'test_helper'

class DummyMethod < SSO::Base
  def initialize(*args)
  end
end

class DummyTrueMethod < DummyMethod
  def available?
    true
  end
end

class DummyFalseMethod < DummyMethod
  def available?
    false
  end
end

class SSOTest < ActiveSupport::TestCase
  def test_get_available_should_find_first_available_method
    SSO.stubs(:all).returns([DummyFalseMethod, DummyTrueMethod, DummyFalseMethod])
    available = SSO.get_available(Object.new)
    assert available.present?
  end

  def test_register_method
    assert_difference 'SSO.all.count', 1 do
      SSO.register_method(DummyMethod)
    end
    assert_includes SSO.all, DummyMethod
  ensure
    SSO.deregister_method(DummyMethod)
  end

  def test_deregister_method
    SSO.register_method(DummyMethod)
    assert_difference 'SSO.all.count', -1 do
      SSO.deregister_method(DummyMethod)
    end
    refute_includes SSO.all, DummyMethod
  end
end
