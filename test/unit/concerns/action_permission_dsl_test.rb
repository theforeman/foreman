require 'test_helper'

module ActionPermissionDslTestModule
  class DummyControllerBase
    def action_permission
      :base_controller_permission
    end
  end

  class DummyController < DummyControllerBase
    include ::Foreman::Controller::ActionPermissionDsl

    attr_accessor :params
  end

  class ActionPermissionDslTest < ActiveSupport::TestCase
    setup do
      @storage = {}
      DummyController.stubs(:action_permissions).returns(@storage)
    end

    test 'it enbales singular initialization' do
      DummyController.define_action_permission :action1, :permission1
      instance = DummyController.new
      instance.params = {:action => :action1}

      actual = instance.action_permission

      assert_equal :permission1, actual
    end

    test 'it enables multiple initialization' do
      DummyController.define_action_permission [:action1, :action2], :permission1
      instance = DummyController.new
      instance.params = {:action => :action1}

      actual = instance.action_permission

      assert_equal :permission1, actual

      instance.params = {:action => :action2}

      actual = instance.action_permission

      assert_equal :permission1, actual
    end

    test 'it enables sequential initializations' do
      DummyController.define_action_permission :action1, :permission1
      DummyController.define_action_permission :action2, :permission1
      instance = DummyController.new
      instance.params = {:action => :action1}

      actual = instance.action_permission

      assert_equal :permission1, actual

      instance.params = {:action => :action2}

      actual = instance.action_permission

      assert_equal :permission1, actual
    end

    test 'it runs the base method if the action was not specified explicitly' do
      DummyController.define_action_permission :action1, :permission1
      instance = DummyController.new
      instance.params = {:action => :other_action}

      actual = instance.action_permission

      assert_equal :base_controller_permission, actual
    end
  end
end
