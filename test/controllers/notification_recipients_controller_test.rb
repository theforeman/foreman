require 'test_helper'

class NotificationRecipientsControllerTest < ActionController::TestCase
  setup do
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end

  test "should get index" do
    get :index, { :format => 'json' }, set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_empty response['notifications']
    assert_equal 0, response['notifications'].size
  end

  test "should get index" do
    notification = add_notification

    get :index, { :format => 'json' }, set_session_user
    assert_response :success
    assert_equal notification.notification_blueprint.message, response['notifications'][0]['text']
  end

  test "should be able to update seen flag" do
    add_notification
    get :index, { :format=>'json' }, set_session_user
    put :update, { :format => 'json', :id => first_notification,
                   :notification_recipient => {:seen => true} }, set_session_user
    assert_response :success
    assert response['seen']
  end

  test "should be able to delete notification" do
    add_notification
    get :index, { :format=>'json' }, set_session_user
    notice_id = first_notification
    assert NotificationRecipient.find(notice_id)
    delete :destroy, { :id => notice_id }
    refute NotificationRecipient.find_by_id(notice_id)
    assert_response :success
  end

  test "should get 404 on invalid notification deletion" do
    get :index, { :format=>'json' }, set_session_user
    notice_id = 1
    refute response['notifications'].map{|n| n['id']}.include?(notice_id)
    refute NotificationRecipient.find_by_id(notice_id)
    delete :destroy, { :id => notice_id }
    assert_response :not_found
  end

  test "should not get notifications if settings login is disabled" do
    SETTINGS[:login] = false
    get :index, { :format=>'json' }, {}
    SETTINGS[:login] = true
    assert_response :not_found
  end

  test "should not respond with expired notifications" do
    notification = add_notification
    notification.update_attribute(:expired_at, Time.now.utc - 48.hours)
    get :index, { :format => 'json' }, set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_empty response['notifications']
  end

  test "notification when host is destroyed" do
    host = FactoryGirl.create(:host)
    assert host.destroy
    get :index, { :format => 'json' }, set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, response['notifications'].size
    assert_equal "#{host} has been deleted successfully", response['notifications'][0]["text"]
  end

  test "notification when host is built" do
    host = FactoryGirl.create(:host, owner: User.current)
    assert host.update_attribute(:build, true)
    assert host.built
    get :index, { :format => 'json' }, set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, response['notifications'].size
    assert_equal "#{host} has been provisioned successfully", response['notifications'][0]["text"]
  end

  test "notification when host has no owner" do
    host = FactoryGirl.create(:host, :managed)
    User.current = nil
    assert host.update_attributes(owner_id: nil, owner_type: nil, build: true)
    assert_nil host.owner
    assert host.built
    get :index, { :format => 'json' }, set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, response['notifications'].size
    assert_equal "#{host} has no owner set", response['notifications'][0]["text"]
  end

  private

  def add_notification
    type = FactoryGirl.create(:notification_blueprint,
                              :message => 'this test just executed successfully')
    FactoryGirl.create(:notification, :notification_blueprint => type, :audience => 'global')
  end

  def response
    ActiveSupport::JSON.decode(@response.body)
  end

  def first_notification
    response['notifications'].first['id']
  end
end
