require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:initiator)
  should validate_presence_of(:notification_type)

  test 'should be able to create notification' do
    type = FactoryGirl.create(:notification_type, :message => 'this test just executed successfully', :audience => 'global')
    notice = FactoryGirl.create(:notification, :notification_type => type)
    assert notice.valid?
    assert_equal type.message, notice.notification_type.message
    assert_nil notice.subject
    assert_equal User.all, notice.recipients
  end

  test 'should return active notifications' do
    type = FactoryGirl.create(:notification_type, :audience => NotificationType::AUDIENCE_ADMIN, :expires_in => 5.minutes)
    notice = FactoryGirl.create(:notification, :notification_type => type)
    assert_includes Notification.active, notice
  end
end
