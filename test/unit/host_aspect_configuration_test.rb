require 'test_helper'

class HostAspectConfigurationTest < ActiveSupport::TestCase
  class TestClass
  end

  test 'enables block configuration' do
    config = HostAspects::Configuration.new
    HostAspects.expects(:configuration).returns(config)

    assert_difference('config.registered_aspects.count', 1) do
      HostAspects.configure do
        register 'TestAspect', :test_model
      end
    end
  end

  test 'gives readonly access to the registry' do
    config = HostAspects::Configuration.new
    config.register 'TestAspect', :test_model
    assert_difference('config.registered_aspects.count', 0) do
      config.registered_aspects.delete(:TestAspect)
    end
  end

  context 'single entry' do
    test 'defaults initialization' do
      config = HostAspects::Configuration.new
      config.register 'TestAspect'
      aspect_configuration = config.registered_aspects[:TestAspect]
      assert_equal :TestAspect, aspect_configuration.name
      assert_equal :test_aspect, aspect_configuration.model
    end

    test 'extended initialization' do
      config = HostAspects::Configuration.new
      config.register 'TestAspect', :test_model do
        add_helper :test_helper
        extend_model :test_extension
      end
      aspect_configuration = config.registered_aspects[:TestAspect]
      assert_equal :TestAspect, aspect_configuration.name
      assert_equal :test_model, aspect_configuration.model
      assert_equal :test_helper, aspect_configuration.helper
      assert_equal :test_extension, aspect_configuration.extension
    end

    test 'exposes xxx_class properties' do
      config = HostAspects::Configuration.new
      config.register 'TestAspect', 'HostAspectConfigurationTest::TestClass'
      aspect_configuration = config.registered_aspects[:TestAspect]
      assert_equal HostAspectConfigurationTest::TestClass, aspect_configuration.model_class
    end
  end
end
