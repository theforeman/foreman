require 'test_helper'

class NotificationRecipientTest < ActiveSupport::TestCase
  should validate_presence_of(:notification)
  should validate_presence_of(:user)

  test "seen should defaults to false" do
    recipient = NotificationRecipient.new
    assert_equal false, recipient.seen
  end

  test "should return unseen notifications" do
    id = FactoryGirl.create(:notification_recipient).id
    assert NotificationRecipient.unseen.pluck(:id).include?(id)
  end
end
