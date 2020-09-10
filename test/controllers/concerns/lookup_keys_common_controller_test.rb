require 'test_helper'

class DummyController
  cattr_accessor :callbacks
  attr_accessor :params

  def self.before_action(*args)
    self.callbacks = args
  end

  include Api::V2::LookupKeysCommonController
end

class Api::V2::LookupKeysCommonControllerTest < ActiveSupport::TestCase
  setup do
    @dummy = DummyController.new
  end

  test "should cast default_value from smart class parameter" do
    @dummy.params = {:smart_class_parameter => { :default_value => ['a', 'b'] }}
    @dummy.cast_value(:smart_class_parameter, :default_value)
    assert_equal ['a', 'b'].to_s, @dummy.params[:smart_class_parameter][:default_value]
  end

  test "should cast value from override value" do
    @dummy.params = {:override_value => { :value => 123 }}
    @dummy.cast_value
    assert_equal "123", @dummy.params[:override_value][:value]
  end
end
