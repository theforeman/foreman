require 'test_helper'

class UINotificationsCacheHandlerTest < ActiveSupport::TestCase
  test 'notification should raise without a subject' do
    assert_raise(Foreman::Exception) { UINotifications::Base.new(nil) }
  end

  test 'should provide JSON payload' do
    response = JSON.parse(UINotifications::CacheHandler.new(User.first.id).payload)
    assert_equal({"notifications" => []}, response)
  end

  test 'should have a unique cache key per user' do
    assert_equal 'notification-1', UINotifications::CacheHandler.new(1).send(:cache_key)
  end

  test 'should use default cache expiry time' do
    expiry = UINotifications::CacheHandler.new(1).send(:cache_expiry)
    assert_equal 1.hour, expiry
  end

  test 'should calculate cache expiry time based on the notification expiry' do
    user = User.first
    blueprint = FactoryBot.build(:notification_blueprint,
      expires_in: 3.hours,
      message: 'this test just executed successfully'
    )
    notification = FactoryBot.create(:notification,
      notification_blueprint: blueprint,
      audience: 'global'
    )
    FactoryBot.build(:notification_recipient,
      notification: notification,
      user_id: user.id
    )
    expiry = UINotifications::CacheHandler.new(user.id).send(:cache_expiry)
    assert (3.hours - expiry < 1000) # time difference is less than a second
  end

  test 'should use be able to clear cache if it exists' do
    Rails.cache.write('notification-1', {notifications: []}.to_json)
    UINotifications::CacheHandler.new(1).clear
    assert_nil Rails.cache.read('notification-1')
  end
end
