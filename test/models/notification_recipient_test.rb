require 'test_helper'

class NotificationRecipientTest < ActiveSupport::TestCase
  should validate_presence_of(:notification)
  should validate_presence_of(:user)

  test "seen should defaults to false" do
    recipient = NotificationRecipient.new
    assert_equal false, recipient.seen
  end

  test "should return unseen notifications" do
    id = FactoryBot.create(:notification_recipient).id
    assert NotificationRecipient.unseen.pluck(:id).include?(id)
  end

  test "destroying triggers clearing user cache" do
    recipient = FactoryBot.create(:notification_recipient)
    UINotifications::CacheHandler.any_instance
                                 .expects(:clear)
    recipient.destroy
  end
end
