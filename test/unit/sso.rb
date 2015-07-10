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
    stub(SSO).all { [ DummyFalseMethod, DummyTrueMethod, DummyFalseMethod ] }
    available = SSO.get_available(Object.new)
    assert available.present?
  end
end
