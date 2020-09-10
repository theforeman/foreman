require 'test_helper'
require 'notifications_test_helper'

class UINotificationsHostsDestroyTest < ActiveSupport::TestCase
  include NotificationBlueprintSeeds

  test 'destroying a host should create a notification' do
    assert_equal 0, Notification.where(:subject => host).count
    host.destroy
    # destory events do not store subject as its being deleted.
    assert_equal 0, Notification.where(:subject => host).count
    assert_equal 1, Notification.where(
      notification_blueprint: blueprint,
      message: "#{host} has been deleted successfully"
    ).count
  end

  test 'destorying host should remove other notification' do
    assert_difference("Notification.where(:subject => host).count", 1) do
      UINotifications::Hosts::BuildCompleted.deliver!(host)
    end
    UINotifications::Hosts::Destroy.deliver!(host)
    assert_equal 0, Notification.where(:subject => host).count
    assert_equal 1, blueprint.notifications.count
  end

  test 'the result of deliver! method should not prevent the deletion of the host' do
    ::UINotifications::Hosts::Destroy.stubs(:deliver!).returns(false)
    assert host.destroy
  end

  private

  def host
    @host ||= FactoryBot.create(:host, :managed)
  end

  def blueprint
    @blueprint ||= NotificationBlueprint.find_by(name: 'host_destroyed')
  end
end
