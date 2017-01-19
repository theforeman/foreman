require 'test_helper'

class UserNotificationsControllerTest < ActionController::TestCase
  setup do
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end

  test "should get index" do
    get :index, { :format=>'json' }, set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_empty response['notifications']
    assert_equal 0, response['total']
  end

  test "should get index" do
    notification = add_notification

    get :index, { :format=>'json' }, set_session_user
    assert_response :success
    expected = {
      'notifications' => [
        {
          "id" => notification.notification_recipients.where(:user_id => users(:admin).id).first.id,
          "level" => "info",
          "text" => "this test just executed successfully",
          "seen" => false
        }
      ],
      'total' => 1
    }
    result = response
    result['notifications'].map{|n| n.except!('created_at')} # ignore creation timestamp
    assert_equal expected, result
  end

  test "should be able to update seen flag" do
    add_notification
    get :index, { :format=>'json' }, set_session_user
    put :update, { :format => 'json', :id => first_notification, :user_notification => {:seen => true} }, set_session_user
    assert_response :success
    assert response['seen']
  end

  test "should be able to delete notificaiton" do
    add_notification
    get :index, { :format=>'json' }, set_session_user
    notice_id = first_notification
    assert_not_nil NotificationRecipient.find(notice_id)
    delete :destroy, { :id => notice_id }
    assert_nil NotificationRecipient.find_by_id(notice_id)
    assert_response :success
  end

  test "should get 404 on invalid notification deletion" do
    get :index, { :format=>'json' }, set_session_user
    notice_id = 1
    refute response['notifications'].map{|n| n['id']}.include?(notice_id)
    assert_nil NotificationRecipient.find_by_id(notice_id)
    delete :destroy, { :id => notice_id }
    assert_response :not_found
  end

  test "should not get notifications if settings login is disabled" do
    SETTINGS[:login] = false
    get :index, { :format=>'json' }, {}
    SETTINGS[:login] = true
    assert_response :not_found
  end

  private

  def add_notification
    type = FactoryGirl.create(:notification_type, :message => 'this test just executed successfully', :audience => 'global')
    FactoryGirl.create(:notification, :notification_type => type)
  end

  def response
    ActiveSupport::JSON.decode(@response.body)
  end

  def first_notification
    response['notifications'].first['id']
  end
end
