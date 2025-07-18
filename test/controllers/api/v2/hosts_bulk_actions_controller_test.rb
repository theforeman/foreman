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

  private

  def set_session_user
    { :user => users(:admin).id }
  end
end
