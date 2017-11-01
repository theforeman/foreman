require 'test_helper'

class NotificationBlueprintTest < ActiveSupport::TestCase
  should validate_presence_of(:message)
  should validate_presence_of(:level)
  should validate_presence_of(:group)
  should validate_presence_of(:name)

  test 'mass_set_seen correctly sets seen on recipients' do
    recipient = FactoryBot.create(:notification_recipient)
    refute recipient.seen
    recipient.notification_blueprint.mass_set_seen(true)
    recipient.reload
    assert recipient.seen
  end
end
