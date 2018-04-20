require 'test_helper'

class ApiHostsControllerExtensionTest < ActiveSupport::TestCase
  setup do
    @klass = Class.new
    @klass.stubs(:before_action).with(:find_resource)
    @klass.send :include, Api::V2::HostsControllerExtension
  end

  test 'adds permissions_check filter when using #check_permissions_for dsl' do
    @klass.stubs :foo
    @klass.expects(:before_action).with(:permissions_check, {:only => [:foo]})
    @klass.check_permissions_for [:foo]
  end

  context '#permissions_check' do
    setup do
      @result = mock('authorized_hosts')
      @instance = @klass.new

      params = { :action => 'permissions_check_test' }
      @instance.stubs(:params).returns(params)
      @host = mock('mock_host')
      @host.stubs(:id).returns(1000)
      @instance.instance_variable_set '@host', @host

      Host.stubs(:authorized).with(:permissions_check_test_hosts, Host).returns(@result)
    end

    teardown do
      # cleanup expectations to class methods
      Host.unstub(:authorized)
    end

    test 'denies access if no hosts found' do
      @result.expects(:find).returns(nil)
      @instance.expects(:deny_access).returns(false)
      actual = @instance.permissions_check
      assert_equal false, actual
    end

    test 'allows access if hosts found' do
      @result.expects(:find).returns(mock('host'))
      actual = @instance.permissions_check
      assert_nil actual
    end
  end
end
