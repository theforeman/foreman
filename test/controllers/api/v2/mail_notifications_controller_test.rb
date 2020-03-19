require 'test_helper'

class Api::V2::MailNotificationsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @user.mail_notifications = [MailNotification.find_by_name('config_summary')]
    @mail_notification = MailNotification.find_by_name('config_error_state')
    @user.save
  end

  test "should create user mail notification" do
    post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }
    assert_response :success
  end

  test "should update user mail notification" do
    post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }
    put :update, params: { :user_id => @user.id, :subscription => 'subscribe to all hosts', :id => @mail_notification.id }
    assert_response :success
  end

  test "should delete user mail notification" do
    post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }
    delete :destroy, params: { :id => @mail_notification.id, :user_id => @user.id }
    assert_response :success
  end
end
