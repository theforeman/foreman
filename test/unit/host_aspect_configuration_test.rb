require 'test_helper'

class HostAspectConfigurationTest < ActiveSupport::TestCase
  class MyCoolClass
  end

  test 'gives readonly access to the registry' do
    config = HostAspects::Configuration.new
    config.register 'MyCoolAspect', :my_cool_model
    hash = config.registered_aspects
    assert_equal 1, hash.count
    hash.delete(:MyCoolAspect)
    assert_equal 0, hash.count
    hash = config.registered_aspects
    assert_equal 1, hash.count
  end

  context 'single entry' do
    test 'defaults initialization' do
      config = HostAspects::Configuration.new
      config.register 'MyCoolAspect'
      res = config.registered_aspects[:MyCoolAspect]
      assert_equal :MyCoolAspect, res.name
      assert_equal :my_cool_aspect, res.model
    end

    test 'extended initialization' do
      config = HostAspects::Configuration.new
      config.register 'MyCoolAspect', :my_cool_model do
        add_helper :my_cool_helper
        extend_model :my_cool_extension
      end
      res = config.registered_aspects[:MyCoolAspect]
      assert_equal :MyCoolAspect, res.name
      assert_equal :my_cool_model, res.model
      assert_equal :my_cool_helper, res.helper
      assert_equal :my_cool_extension, res.extension
    end

    test 'exposes xxx_class properties' do
      config = HostAspects::Configuration.new
      config.register 'MyCoolAspect', 'HostAspectConfigurationTest::MyCoolClass'
      res = config.registered_aspects[:MyCoolAspect]
      assert_equal HostAspectConfigurationTest::MyCoolClass, res.model_class
    end
  end
end
