require 'test_helper'
require 'notifications_test_helper'

class NotificationRecipientsControllerTest < ActionController::TestCase
  setup do
    @request.headers['Accept'] = Mime[:json]
    @request.headers['Content-Type'] = Mime[:json].to_s
  end

  test "should get index" do
    get :index, params: { :format => 'json' }, session: set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_empty response['notifications']
    assert_equal 0, response['notifications'].size
  end

  test "should get index" do
    notification = add_notification

    get :index, params: { :format => 'json' }, session: set_session_user
    assert_response :success
    assert_equal notification.notification_blueprint.message, response['notifications'][0]['text']
  end

  test "should be able to update seen flag" do
    add_notification
    get :index, params: { :format => 'json' }, session: set_session_user
    put :update, params: { :format => 'json', :id => first_notification,
                           :notification_recipient => {:seen => true} }, session: set_session_user
    assert_response :success
    assert response['seen']
  end

  test "should be able to delete notification" do
    add_notification
    get :index, params: { :format => 'json' }, session: set_session_user
    notice_id = first_notification
    assert NotificationRecipient.find(notice_id)
    delete :destroy, params: { :id => notice_id }
    refute NotificationRecipient.find_by_id(notice_id)
    assert_response :success
  end

  test "should get 404 on invalid notification deletion" do
    get :index, params: { :format => 'json' }, session: set_session_user
    notice_id = 1
    refute response['notifications'].map { |n| n['id'] }.include?(notice_id)
    refute NotificationRecipient.find_by_id(notice_id)
    delete :destroy, params: { :id => notice_id }
    assert_response :not_found
  end

  test "should not respond with expired notifications" do
    notification = add_notification
    notification.update_attribute(:expired_at, Time.now.utc - 48.hours)
    get :index, params: { :format => 'json' }, session: set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_empty response['notifications']
  end

  context "with seeded notification types" do
    include NotificationBlueprintSeeds

    test "notification when host is destroyed" do
      host = FactoryBot.create(:host)
      assert host.destroy
      get :index, params: { :format => 'json' }, session: set_session_user
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 1, response['notifications'].size
      assert_equal "#{host} has been deleted successfully", response['notifications'][0]["text"]
    end

    test "notification when host is built" do
      host = FactoryBot.create(:host, owner: User.current)
      assert host.update_attribute(:build, true)
      assert host.built
      get :index, params: { :format => 'json' }, session: set_session_user
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 1, response['notifications'].size
      assert_equal "#{host} has been provisioned successfully", response['notifications'][0]["text"]
    end

    test "notification when host has no owner" do
      host = FactoryBot.create(:host, :managed)
      assert host.update_attribute(:owner_id, nil)
      Host::Managed.where(:owner_id => nil).update_all(:owner_type => nil) # owner type must be set by hack because of sti.rb
      host.reload
      assert host.update_attribute(:build, false)
      assert_nil host.owner

      setup_user 'edit', 'hosts'
      host.stub :owner_suggestion, nil do
        assert host.built
      end

      as_admin do
        get :index, params: { :format => 'json' }, session: set_session_user
      end
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 1, response['notifications'].size
      assert_equal "#{host} has no owner set", response['notifications'][0]["text"]
    end
  end

  test 'group mark as read' do
    add_notification
    query = {user_id: User.current.id, seen: false}
    assert_equal 1, NotificationRecipient.where(query).count
    put :update_group_as_read, params: { :group => 'Testing' }, session: set_session_user
    assert_response :success
    assert_equal 1, NotificationRecipient.where(query.merge({seen: true})).count
    assert_equal 0, NotificationRecipient.where(query).count
  end

  test 'group mark as read twice' do
    add_notification
    put :update_group_as_read, params: { :group => 'Testing' }, session: set_session_user
    assert_response :success
    put :update_group_as_read, params: { :group => 'Testing' }, session: set_session_user
    assert_response :not_modified
  end

  test 'invalid group mark as read' do
    put :update_group_as_read, params: { :group => 'unknown;INSERT INTO users (user_id, group)' }, session: set_session_user
    assert_response :not_modified
  end

  test 'group mark as read only update the correct group' do
    add_notification('Group1')
    add_notification('Group2')
    query = {user_id: User.current.id, seen: false}
    assert_equal 2, NotificationRecipient.where(query).count
    put :update_group_as_read, params: { :group => 'Group1' }, session: set_session_user
    assert_response :success
    assert_equal 1, NotificationRecipient.where(query.merge({seen: true})).count
    assert_equal 0, NotificationRecipient.where(query).
      joins(:notification_blueprint).
      where(notification_blueprints: { group: 'Group1' }).count
    assert_equal 1, NotificationRecipient.where(query).
      joins(:notification_blueprint).
      where(notification_blueprints: { group: 'Group2' }).count
  end

  test 'delete group notifications' do
    add_notification
    query = {user_id: User.current.id}
    assert_equal 1, NotificationRecipient.where(query).count
    delete :destroy_group, params: { :group => 'Testing' }, session: set_session_user
    assert_response :success
    assert_equal 0, NotificationRecipient.where(query).count
  end

  test 'group delete when multiple groups exists' do
    add_notification('Group1')
    add_notification('Group2')
    query = {user_id: User.current.id}
    assert_equal 2, NotificationRecipient.where(query).count
    delete :destroy_group, params: { :group => 'Group1' }, session: set_session_user
    assert_response :success
    assert_equal 1, NotificationRecipient.where(query).count
    assert_equal 0, NotificationRecipient.where(query).
      joins(:notification_blueprint).
      where(notification_blueprints: { group: 'Group1' }).count
    assert_equal 1, NotificationRecipient.where(query).
      joins(:notification_blueprint).
      where(notification_blueprints: { group: 'Group2' }).count
  end

  private

  def add_notification(group = 'Testing')
    type = FactoryBot.create(:notification_blueprint,
      :group => group,
      :message => 'this test just executed successfully')
    FactoryBot.create(:notification, :notification_blueprint => type, :audience => 'global')
  end

  def response
    ActiveSupport::JSON.decode(@response.body)
  end

  def first_notification
    response['notifications'].first['id']
  end
end
