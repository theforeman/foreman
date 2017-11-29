require 'test_helper'
require 'ostruct'

module UINotifications
  class RssNotificationsCheckerTest < ActiveSupport::TestCase
    context 'when force_repost is disabled' do
      setup do
        @notifications_service = RssNotificationsChecker.new(:force_repost => false)
      end

      test 'already existing notifications are not created' do
        feed = OpenStruct.new(:items => [1,2,3])
        RSS::Parser.expects(:parse).returns(feed)
        Notification.expects(:create).never
        @notifications_service.expects(:notification_already_exists?).
          returns(true).at_least_once
        @notifications_service.deliver!
      end
    end
  end
end
