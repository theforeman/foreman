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

  test "should create user mail notification with skip_if_empty" do
    summary = FactoryBot.create(:mail_notification, :skippable)
    post :create, params: { user_id: @user.id, interval: 'daily', mail_notification_id: summary.id, skip_if_empty: true }
    assert_response :success
    assert @user.reload.user_mail_notifications.find_by(mail_notification_id: summary.id).skip_if_empty
  end

  test "should not accept skip_if_empty for a notification that cannot be skipped" do
    notification = FactoryBot.create(:mail_notification)
    post :create, params: { user_id: @user.id, interval: 'daily', mail_notification_id: notification.id, skip_if_empty: true }
    assert_response :error
  end

  test "should delete user mail notification" do
    post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }
    delete :destroy, params: { :id => @mail_notification.id, :user_id => @user.id }
    assert_response :success
  end

  context 'with non-admin user' do
    test 'lists its own mail notifications' do
      caller = FactoryBot.create(:user)
      FactoryBot.create(:user_mail_notification, :user => caller, :mail_notification => @mail_notification)
      setup_user('view', 'mail_notifications', nil, caller)

      get :user_mail_notifications, params: { :id => caller.id }, session: set_session_user(caller)

      assert_response :success
      assert_includes @response.body, @mail_notification.name
    end

    test 'lists mail notifications for a user in its edit_users filter' do
      caller = FactoryBot.create(:user)
      setup_user('view', 'mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{@user.id}", caller)

      get :user_mail_notifications, params: { :id => @user.id }, session: set_session_user(caller)

      assert_response :success
      assert_includes @response.body, 'config_summary'
    end

    test 'does not disclose mail notifications for a user outside its edit_users filter' do
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      subscription = @user.user_mail_notifications.first
      subscription.update!(:interval => 'Weekly', :mail_query => 'sensitive search', :last_sent => 2.days.ago, :skip_if_empty => true)
      setup_user('view', 'mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      get :user_mail_notifications, params: { :id => @user.id }, session: set_session_user(caller)

      assert_response :not_found
      response = JSON.parse(@response.body)
      response_keys = response.is_a?(Array) ? response.flat_map(&:keys) : response.keys
      serialized_keys = subscription.attributes.keys + %w[name description]
      assert_empty serialized_keys & response_keys
    end

    test 'does not create a mail notification for a user outside its edit_users filter' do
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      assert_no_difference('UserMailNotification.count') do
        post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :not_found
    end

    test 'creates a mail notification for a user in its edit_users filter' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{@user.id}", caller)

      assert_difference('UserMailNotification.count') do
        post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :success
    end

    test 'creates its own mail notification' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)

      assert_difference('UserMailNotification.count') do
        post :create, params: { :user_id => caller.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :success
    end

    test 'does not update interval, query, or skip behavior for a user outside its edit_users filter' do
      notification = FactoryBot.create(:mail_notification, :queryable, :skippable)
      subscription = FactoryBot.create(
        :user_mail_notification,
        :user => @user,
        :mail_notification => notification,
        :interval => 'Daily',
        :mail_query => 'original search',
        :skip_if_empty => true
      )
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      put :update, params: { :user_id => @user.id, :interval => 'weekly', :mail_query => 'altered search', :skip_if_empty => false, :id => notification.id }, session: set_session_user(caller)

      assert_response :not_found
      assert_equal({ 'interval' => 'Daily', 'mail_query' => 'original search', 'skip_if_empty' => true }, subscription.reload.attributes.slice('interval', 'mail_query', 'skip_if_empty'))
    end

    test 'does not update subscription mode for a user outside its edit_users filter' do
      subscription = FactoryBot.create(:user_mail_notification, :user => @user, :mail_notification => @mail_notification, :interval => 'Subscribe to my hosts')
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      put :update, params: { :user_id => @user.id, :subscription => 'subscribe to all hosts', :id => @mail_notification.id }, session: set_session_user(caller)

      assert_response :not_found
      assert_equal 'Subscribe to my hosts', subscription.reload.interval
    end

    test 'updates its own mail notification' do
      caller = FactoryBot.create(:user)
      subscription = FactoryBot.create(:user_mail_notification, :user => caller, :mail_notification => @mail_notification, :interval => 'Subscribe to my hosts')
      setup_user('edit', 'user_mail_notifications', nil, caller)

      put :update, params: { :user_id => caller.id, :subscription => 'subscribe to all hosts', :id => @mail_notification.id }, session: set_session_user(caller)

      assert_response :success
      assert_equal 'Subscribe to all hosts', subscription.reload.interval
    end

    test 'updates a mail notification for a user in its edit_users filter' do
      subscription = FactoryBot.create(:user_mail_notification, :user => @user, :mail_notification => @mail_notification, :interval => 'Subscribe to my hosts')
      caller = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{@user.id}", caller)

      put :update, params: { :user_id => @user.id, :subscription => 'subscribe to all hosts', :id => @mail_notification.id }, session: set_session_user(caller)

      assert_response :success
      assert_equal 'Subscribe to all hosts', subscription.reload.interval
    end

    test 'does not delete a mail notification for a user outside its edit_users filter' do
      subscription = FactoryBot.create(:user_mail_notification, :user => @user, :mail_notification => @mail_notification)
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      assert_no_difference('UserMailNotification.count') do
        delete :destroy, params: { :user_id => @user.id, :id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :not_found
      assert subscription.reload.persisted?
    end

    test 'deletes its own mail notification' do
      caller = FactoryBot.create(:user)
      FactoryBot.create(:user_mail_notification, :user => caller, :mail_notification => @mail_notification)
      setup_user('edit', 'user_mail_notifications', nil, caller)

      assert_difference('UserMailNotification.count', -1) do
        delete :destroy, params: { :user_id => caller.id, :id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :success
    end

    test 'deletes a mail notification for a user in its edit_users filter' do
      FactoryBot.create(:user_mail_notification, :user => @user, :mail_notification => @mail_notification)
      caller = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', "id = #{@user.id}", caller)

      assert_difference('UserMailNotification.count', -1) do
        delete :destroy, params: { :user_id => @user.id, :id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :success
    end

    test 'requires view_mail_notifications when listing another user notifications' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'users', nil, caller)

      get :user_mail_notifications, params: { :id => @user.id }, session: set_session_user(caller)

      assert_response :forbidden
      refute_includes @response.body, 'config_summary'
    end

    test 'requires edit_user_mail_notifications when changing another user notifications' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'users', nil, caller)

      assert_no_difference('UserMailNotification.count') do
        post :create, params: { :user_id => @user.id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :forbidden
    end

    test 'does not list notifications for a missing user' do
      caller = FactoryBot.create(:user)
      setup_user('view', 'mail_notifications', nil, caller)
      setup_user('edit', 'users', nil, caller)

      get :user_mail_notifications, params: { :id => User.maximum(:id) + 1 }, session: set_session_user(caller)

      assert_response :not_found
    end

    test 'does not create notifications for a hidden user' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'user_mail_notifications', nil, caller)
      setup_user('edit', 'users', nil, caller)

      assert_no_difference('UserMailNotification.count') do
        post :create, params: { :user_id => users(:apiadmin).id, :subscription => 'subscribe to my hosts', :mail_notification_id => @mail_notification.id }, session: set_session_user(caller)
      end

      assert_response :not_found
    end
  end
end
