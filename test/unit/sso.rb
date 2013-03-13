require 'test_helper'

class DummyMethod < Sso::Base
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

class SsoTest < ActiveSupport::TestCase
  def test_get_available_should_find_first_available_method
    stub(Sso).all { [ DummyFalseMethod, DummyTrueMethod, DummyFalseMethod ] }
    available = Sso.get_available(Object.new)
    assert_present available
  end
end
