require 'test_helper'
require 'notifications_test_helper'

class UINotificationsHostsBuildCompletedTest < ActiveSupport::TestCase
  include NotificationBlueprintSeeds

  test 'create new host build notification' do
    host.update_attribute(:build, true)
    assert_difference("blueprint.notifications.where(:subject => host).count", 1) do
      assert host.built
    end
  end

  test 'multiple build events should update current build notification' do
    assert_difference("Notification.where(:subject => host).count", 1) do
      host.built
      host.setBuild
      host.built
    end
  end

  private

  def host
    @host ||= FactoryBot.build(:host, :managed)
  end

  def blueprint
    @blueprint ||= NotificationBlueprint.find_by(name: 'host_build_completed')
  end
end
