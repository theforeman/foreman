require 'test_helper'

class NotificationBlueprintTest < ActiveSupport::TestCase
  should validate_presence_of(:message)
  should validate_presence_of(:level)
  should validate_presence_of(:group)
  should validate_presence_of(:name)
end
