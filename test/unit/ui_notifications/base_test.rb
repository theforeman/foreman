require 'test_helper'

class UINotificationsTest < ActiveSupport::TestCase
  test 'notification should raise without a subject' do
    assert_raise(Foreman::Exception) { UINotifications::Base.new(nil) }
  end

  test 'notification logger exists' do
    assert_equal 'notifications', Foreman::Logging.logger('notifications').name
  end

  test 'event should default to class name' do
    class Event < ::UINotifications::Base; end
    assert_equal "Event", Event.new(Object.new).send(:event)
  end
end
