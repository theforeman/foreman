require 'test_helper'

class Api::V2::HostsBulkActionsControllerTest < ActionController::TestCase
  def setup
    as_admin do
      @organization = FactoryBot.create(:organization)
      @location = FactoryBot.create(:location)
      @host1 = FactoryBot.create(:host, :managed, :organization => @organization, :location => @location)
      @host2 = FactoryBot.create(:host, :managed, :organization => @organization, :location => @location)
      @host3 = FactoryBot.create(:host, :managed, :organization => @organization, :location => @location)
      @user = FactoryBot.create(:user, :organizations => [@organization], :locations => [@location])
      @usergroup = FactoryBot.create(:usergroup)
      @host_ids = [@host1.id, @host2.id, @host3.id]
    end
  end

  def valid_bulk_params(host_ids = @host_ids)
    {
      :organization_id => @organization.id,
      :included => {
        :ids => host_ids,
      },
      :excluded => {
        :ids => [],
      },
    }
  end

  def valid_power_params(host_ids = @host_ids, action = 'start')
    valid_bulk_params(host_ids).merge(:power => action)
  end

  test "should change owner with user id" do
    put :change_owner, params: valid_bulk_params.merge(:owner_id => @user.id_and_type)

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated hosts: changed owner/, response['message'])

    [@host1, @host2, @host3].each do |host|
      host.reload
      assert_equal @user.id_and_type, host.is_owned_by
    end
  end

  test "should change owner with usergroup id" do
    put :change_owner, params: valid_bulk_params.merge(:owner_id => @usergroup.id_and_type)

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated hosts: changed owner/, response['message'])

    [@host1, @host2, @host3].each do |host|
      host.reload
      assert_equal @usergroup.id_and_type, host.is_owned_by
    end
  end

  test "should handle single host ownership change" do
    single_host_params = valid_bulk_params([@host1.id])

    put :change_owner, params: single_host_params.merge(:owner_id => @user.id_and_type)

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated host: changed owner/, response['message'])

    @host1.reload
    assert_equal @user.id_and_type, @host1.is_owned_by
  end

  test "should require owner_id parameter" do
    put :change_owner, params: valid_bulk_params

    assert_response :success
  end

  test "should call BulkHostsManager with correct parameters" do
    bulk_manager = mock('BulkHostsManager')
    BulkHostsManager.expects(:new).with(hosts: anything).returns(bulk_manager)
    bulk_manager.expects(:change_owner).with(@user.id_and_type)

    put :change_owner, params: valid_bulk_params.merge(:owner_id => @user.id_and_type)

    assert_response :success
  end

  context "with different host counts" do
    test "should handle pluralization correctly for single host" do
      single_host_params = valid_bulk_params([@host1.id])

      put :change_owner, params: single_host_params.merge(:owner_id => @user.id_and_type)

      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      # Should use singular form "host" not "hosts"
      assert_match(/Updated host: changed owner/, response['message'])
    end

    test "should handle pluralization correctly for multiple hosts" do
      put :change_owner, params: valid_bulk_params.merge(:owner_id => @user.id_and_type)

      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      # Should use plural form "hosts"
      assert_match(/Updated hosts: changed owner/, response['message'])
    end
  end

  context "change_power_state" do
    test "successfully changes power state for all hosts" do
      Host.any_instance.stubs(:supports_power?).returns(true)
      power_mock = mock('power')
      Host.any_instance.stubs(:power).returns(power_mock)
      power_mock.expects(:send).with(:start).times(@host_ids.size)

      put :change_power_state, params: valid_power_params(@host_ids, 'start')

      assert_response :success
      body = ActiveSupport::JSON.decode(@response.body)
      assert_match(/The power state of the selected hosts will be set to start/, body['message'])
    end

    test "returns failed_host_ids when all hosts fail" do
      Host.any_instance.stubs(:supports_power?).returns(true)
      power_mock = mock('power')
      Host.any_instance.stubs(:power).returns(power_mock)
      power_mock.stubs(:send).with(:start).raises(StandardError.new('Power operation failed'))

      put :change_power_state, params: valid_power_params(@host_ids, 'start')

      assert_response :unprocessable_entity
      body = ActiveSupport::JSON.decode(@response.body)
      assert_match(/Failed to set power state for 3 hosts/, body['error']['message'])
      assert_equal @host_ids.sort, body['error']['failed_host_ids'].sort
    end

    test "returns error when power param is missing" do
      Host.any_instance.stubs(:supports_power?).returns(true)
      power_mock = mock('power')
      Host.any_instance.stubs(:power).returns(power_mock)
      power_mock.stubs(:send).raises(StandardError.new('Power operation failed'))

      put :change_power_state, params: valid_bulk_params(@host_ids)

      assert_response :unprocessable_entity
      body = ActiveSupport::JSON.decode(@response.body)
      assert_equal "Power action is required", body['error']['message']
      assert_equal @host_ids.sort, body['error']['failed_host_ids'].sort
    end

    test "returns error when power action is invalid" do
      put :change_power_state, params: valid_power_params(@host_ids, 'invalid')

      assert_response :unprocessable_entity
      body = ActiveSupport::JSON.decode(@response.body)
      assert_equal "Invalid power action", body['error']['message']
      assert_equal PowerManager::REAL_ACTIONS, body['error']['valid_power_actions']
      assert_equal @host_ids.sort, body['error']['failed_host_ids'].sort
    end

    test "handles mixed hosts with no power support, failure, and success" do
      Host.any_instance.stubs(:supports_power?)
                      .returns(false)
                      .then.returns(true)
                      .then.returns(true)

      power_fail = mock('power_fail')
      power_ok   = mock('power_ok')

      Host.any_instance.stubs(:power)
                      .returns(power_fail)
                      .then.returns(power_ok)

      power_fail.expects(:send).with(:start).raises(StandardError.new('Power operation failed'))
      power_ok.expects(:send).with(:start)

      put :change_power_state, params: valid_power_params(@host_ids, 'start')

      assert_response :unprocessable_entity
      body = ActiveSupport::JSON.decode(@response.body)
      # Message should contain both failure types
      assert_match(/Failed to set power state for 1 host/, body['error']['message'])
      assert_match(/1 host does not support power management/, body['error']['message'])
      assert_equal 2, body['error']['failed_host_ids'].size
      body['error']['failed_host_ids'].each do |id|
        assert_includes @host_ids, id
      end
    end
  end

  context "manage_notifications" do
    test "should enable notifications for all hosts" do
      @hosts = [@host1, @host2, @host3]
      @hosts.each { |host| host.update_attribute(:enabled, false) }

      put :manage_notifications, params: valid_bulk_params.merge(:enabled => true)

      assert_response :success
      body = ActiveSupport::JSON.decode(@response.body)
      assert_match(/Notifications enabled for 3 hosts/, body['message'])

      @hosts.each do |host|
        host.reload
        assert host.enabled?, "Expected #{host.name} to be enabled"
      end
    end

    test "should disable notifications for all hosts" do
      put :manage_notifications, params: valid_bulk_params.merge(:enabled => false)

      assert_response :success
      body = ActiveSupport::JSON.decode(@response.body)
      assert_match(/Notifications disabled for 3 hosts/, body['message'])

      [@host1, @host2, @host3].each do |host|
        host.reload
        refute host.enabled?, "Expected #{host.name} to be disabled"
      end
    end

    test "should handle single host notification change" do
      single_host_params = valid_bulk_params([@host1.id])

      put :manage_notifications, params: single_host_params.merge(:enabled => true)

      assert_response :success
      body = ActiveSupport::JSON.decode(@response.body)
      assert_match(/Notifications enabled for 1 host/, body['message'])
    end
  end

  private

  def set_session_user
    { :user => users(:admin).id }
  end
end
